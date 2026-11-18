# Part D: Model Context Protocol (MCP) JSON-RPC Execution & Inspection

This document records the exact JSON-RPC 2.0 communication between the automated test client and the `campus-helpdesk-mcp` server executing over standard input/output (`stdio`).

---

## 1. Protocol Version Negotiation

- **Negotiated MCP Protocol Version**: `2024-11-05`
- **Verification Source**: Extracted directly from the server's `initialize` handshake response:
  ```json
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "experimental": {},
      "prompts": { "listChanged": false },
      "resources": { "subscribe": false, "listChanged": false },
      "tools": { "listChanged": false }
    },
    "serverInfo": {
      "name": "campus-helpdesk-mcp",
      "version": "1.26.0"
    }
  }
  ```

---

## 2. JSON-RPC Message Log & Plain English Annotations

### Step 1: `initialize` Handshake

#### Client Request (ID: 1)
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "roots": {
        "listChanged": false
      },
      "sampling": {}
    },
    "clientInfo": {
      "name": "campus-helpdesk-test-client",
      "version": "1.0.0"
    }
  }
}
```
> **Plain English Annotation:** The client initiates the stdio session by proposing protocol version `2024-11-05` and advertising its capabilities (`roots`, `sampling`) along with client identity information.

#### Server Response (ID: 1)
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "experimental": {},
      "prompts": {
        "listChanged": false
      },
      "resources": {
        "subscribe": false,
        "listChanged": false
      },
      "tools": {
        "listChanged": false
      }
    },
    "serverInfo": {
      "name": "campus-helpdesk-mcp",
      "version": "1.26.0"
    }
  }
}
```
> **Plain English Annotation:** The server accepts protocol version `2024-11-05`, confirms server identity (`campus-helpdesk-mcp` v1.26.0), and advertises supported capabilities (prompts, resources, and tools).

#### Client Notification (Initialized)
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized"
}
```
> **Plain English Annotation:** The client sends a one-way JSON-RPC notification confirming that the handshake is complete and standard operations may begin.

---

### Step 2: `tools/list` Discovery

#### Client Request (ID: 2)
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/list",
  "params": {}
}
```
> **Plain English Annotation:** The client requests the catalog of all tools exposed by the MCP server along with their input parameter schemas.

#### Server Response (ID: 2)
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "tools": [
      {
        "name": "get_timetable",
        "description": "Retrieve the class timetable schedule for a given batch and day.\n\nArgs:\n    batch: The student cohort or batch identifier (e.g. 'Semester 3, Section A', 'Sem 3A', '3-A').\n    day: The day of the week to query (e.g. 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday').\n\nReturns:\n    A JSON string containing the matching schedule records, or a structured not-found error message.\n",
        "inputSchema": {
          "properties": {
            "batch": {
              "title": "Batch",
              "type": "string"
            },
            "day": {
              "title": "Day",
              "type": "string"
            }
          },
          "required": [
            "batch",
            "day"
          ],
          "title": "get_timetableArguments",
          "type": "object"
        },
        "outputSchema": {
          "properties": {
            "result": {
              "title": "Result",
              "type": "string"
            }
          },
          "required": [
            "result"
          ],
          "title": "get_timetableOutput",
          "type": "object"
        }
      },
      {
        "name": "get_fee_status",
        "description": "Look up the academic fee payment status for a student by their Student ID.\n\nArgs:\n    student_id: The unique student identifier (e.g. 'STU1001', 'STU1002', 'STU1003', 'STU1004', 'STU1005').\n\nReturns:\n    A JSON string with the fee status (Paid, Pending, Overdue) and balance details.\n",
        "inputSchema": {
          "properties": {
            "student_id": {
              "title": "Student Id",
              "type": "string"
            }
          },
          "required": [
            "student_id"
          ],
          "title": "get_fee_statusArguments",
          "type": "object"
        },
        "outputSchema": {
          "properties": {
            "result": {
              "title": "Result",
              "type": "string"
            }
          },
          "required": [
            "result"
          ],
          "title": "get_fee_statusOutput",
          "type": "object"
        }
      }
    ]
  }
}
```
> **Plain English Annotation:** The server returns two registered tools: `get_timetable` (requires `batch` and `day`) and `get_fee_status` (requires `student_id`). Each tool includes JSON schema validation requirements and human-readable parameter documentation.

---

### Step 3: `tools/call` for `get_timetable` (Success Case)

#### Client Request (ID: 3)
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "get_timetable",
    "arguments": {
      "batch": "Semester 3, Section A",
      "day": "Monday"
    }
  }
}
```
> **Plain English Annotation:** The client invokes `get_timetable` specifying batch `"Semester 3, Section A"` and day `"Monday"`.

#### Server Response (ID: 3)
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\n  \"status\": \"success\",\n  \"batch\": \"Semester 3, Section A\",\n  \"day\": \"Monday\",\n  \"data_source\": \"csv\",\n  \"count\": 3,\n  \"records\": [\n    {\n      \"day\": \"Monday\",\n      \"start_time\": \"09:00\",\n      \"end_time\": \"10:00\",\n      \"subject\": \"Data Structures\",\n      \"faculty\": \"Dr. Sharma\",\n      \"room\": \"Lab 301\",\n      \"semester\": \"3\",\n      \"section\": \"A\"\n    },\n    {\n      \"day\": \"Monday\",\n      \"start_time\": \"10:00\",\n      \"end_time\": \"11:00\",\n      \"subject\": \"Database Management Systems\",\n      \"faculty\": \"Prof. Mehta\",\n      \"room\": \"Room 204\",\n      \"semester\": \"3\",\n      \"section\": \"A\"\n    },\n    {\n      \"day\": \"Monday\",\n      \"start_time\": \"11:15\",\n      \"end_time\": \"12:15\",\n      \"subject\": \"Operating Systems\",\n      \"faculty\": \"Dr. Rao\",\n      \"room\": \"Room 205\",\n      \"semester\": \"3\",\n      \"section\": \"A\"\n    }\n  ]\n}"
      }
    ],
    "structuredContent": {
      "result": "{\n  \"status\": \"success\",\n  \"batch\": \"Semester 3, Section A\",\n  \"day\": \"Monday\",\n  \"data_source\": \"csv\",\n  \"count\": 3,\n  \"records\": [\n    {\n      \"day\": \"Monday\",\n      \"start_time\": \"09:00\",\n      \"end_time\": \"10:00\",\n      \"subject\": \"Data Structures\",\n      \"faculty\": \"Dr. Sharma\",\n      \"room\": \"Lab 301\",\n      \"semester\": \"3\",\n      \"section\": \"A\"\n    },\n    {\n      \"day\": \"Monday\",\n      \"start_time\": \"10:00\",\n      \"end_time\": \"11:00\",\n      \"subject\": \"Database Management Systems\",\n      \"faculty\": \"Prof. Mehta\",\n      \"room\": \"Room 204\",\n      \"semester\": \"3\",\n      \"section\": \"A\"\n    },\n    {\n      \"day\": \"Monday\",\n      \"start_time\": \"11:15\",\n      \"end_time\": \"12:15\",\n      \"subject\": \"Operating Systems\",\n      \"faculty\": \"Dr. Rao\",\n      \"room\": \"Room 205\",\n      \"semester\": \"3\",\n      \"section\": \"A\"\n    }\n  ]\n}"
    },
    "isError": false
  }
}
```
> **Plain English Annotation:** The server successfully queries the dataset, confirms `isError: false`, and returns three scheduled Monday courses (Data Structures, DBMS, and Operating Systems) in both plain text and structured JSON formats.

---

### Step 4: `tools/call` for `get_timetable` (Failure Case: `day="Funday"`)

#### Client Request (ID: 8)
```json
{
  "jsonrpc": "2.0",
  "id": 8,
  "method": "tools/call",
  "params": {
    "name": "get_timetable",
    "arguments": {
      "batch": "Semester 3, Section A",
      "day": "Funday"
    }
  }
}
```
> **Plain English Annotation:** The client invokes `get_timetable` with an invalid weekday value (`"Funday"`).

#### Server Response (ID: 8)
```json
{
  "jsonrpc": "2.0",
  "id": 8,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\n  \"status\": \"error\",\n  \"batch\": \"Semester 3, Section A\",\n  \"day\": \"Funday\",\n  \"data_source\": \"csv\",\n  \"message\": \"Invalid day 'Funday'. Allowed values: Monday, Tuesday, Wednesday, Thursday, Friday.\",\n  \"records\": []\n}"
      }
    ],
    "structuredContent": {
      "result": "{\n  \"status\": \"error\",\n  \"batch\": \"Semester 3, Section A\",\n  \"day\": \"Funday\",\n  \"data_source\": \"csv\",\n  \"message\": \"Invalid day 'Funday'. Allowed values: Monday, Tuesday, Wednesday, Thursday, Friday.\",\n  \"records\": []\n}"
    },
    "isError": false
  }
}
```
> **Plain English Annotation:** The server handles the error gracefully at the application layer. Rather than crashing the transport or emitting an unhandled JSON-RPC error, it returns a structured JSON payload with `"status": "error"`, an empty `records` array, and an explicit explanatory message (`"Invalid day 'Funday'. Allowed values: Monday, Tuesday, Wednesday, Thursday, Friday."`). Note that `isError` remains `false` because the tool executed cleanly and safely caught the domain-level validation error.

---

## 3. Package Verification: `npm view @nimbus/mcp-skill-bridge`

Execution command:
```bash
npm view @nimbus/mcp-skill-bridge
```

Actual terminal output:
```text
npm error code E404
npm error 404 Not Found - GET https://registry.npmjs.org/@nimbus%2fmcp-skill-bridge - Not found
npm error 404
npm error 404  '@nimbus/mcp-skill-bridge@*' is not in this registry.
npm error 404
npm error 404 Note that you can also install from a
npm error 404 tarball, folder, http url, or git url.
```

**Verification Finding**: The HTTP `404 Not Found` response from the official npm registry (`registry.npmjs.org`) confirms that `@nimbus/mcp-skill-bridge` is **not a real published npm package**.

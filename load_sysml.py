#!/usr/bin/env python3
"""
Syson Project Loader
Automatically creates a project in Syson and loads a SysML model
"""

import requests
import json
import time
import os
import sys
import uuid

# Configuration
SYSON_URL = "http://localhost:8080"
SYSON_GRAPHQL_URL = f"{SYSON_URL}/api/graphql"
PROJECT_NAME = "AlpsRescueDroneSystem"
SYSML_FILE = "/teamspace/studios/this_studio/agdesign/new.sysml"

# Colors for output
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'  # No Color

def print_status(message, status="info"):
    """Print status message with color"""
    if status == "success":
        print(f"{GREEN}✓ {message}{NC}")
    elif status == "error":
        print(f"{RED}✗ {message}{NC}")
    else:
        print(f"{YELLOW}→ {message}{NC}")

def check_syson_health():
    """Check if Syson is running"""
    try:
        response = requests.get(SYSON_URL, timeout=5)
        return response.status_code == 200
    except:
        return False

def query_graphql(query_str, variables=None):
    """Execute a GraphQL query against Syson"""
    payload = {
        "query": query_str,
        "variables": variables or {}
    }
    
    try:
        response = requests.post(
            SYSON_GRAPHQL_URL,
            json=payload,
            timeout=10
        )
        return response.json()
    except Exception as e:
        print_status(f"GraphQL request failed: {str(e)}", "error")
        return None

def create_project():
    """Create a new project in Syson"""
    query = """
    mutation CreateProject($input: CreateProjectInput!) {
        createProject(input: $input) {
            __typename
            ... on CreateProjectSuccessPayload {
                project {
                    id
                    name
                }
            }
            ... on ErrorPayload {
                message
            }
        }
    }
    """
    
    # Generate a proper UUID
    project_id = str(uuid.uuid4())
    
    variables = {
        "input": {
            "id": project_id,
            "name": PROJECT_NAME,
            "natures": []
        }
    }
    
    result = query_graphql(query, variables)
    
    if result and "data" in result:
        payload = result["data"].get("createProject", {})
        if payload.get("__typename") == "CreateProjectSuccessPayload":
            created_id = payload.get("project", {}).get("id")
            print_status(f"Created project '{PROJECT_NAME}' (ID: {created_id})", "success")
            return created_id
    
    print_status(f"Failed to create project. Response: {result}", "error")
    return None

def create_document(project_id, document_name):
    """Create a document in the project"""
    query = """
    mutation CreateDocument($input: CreateDocumentInput!) {
      createDocument(input: $input) {
        __typename
        ... on CreateDocumentSuccessPayload {
          document {
            id
            name
          }
        }
        ... on ErrorPayload {
          message
        }
      }
    }
    """
    
    document_id = str(uuid.uuid4())
    
    variables = {
        "input": {
            "id": document_id,
            "project": project_id,
            "name": document_name
        }
    }
    
    result = query_graphql(query, variables)
    
    if result and "data" in result:
        payload = result["data"].get("createDocument", {})
        if payload.get("__typename") == "CreateDocumentSuccessPayload":
            created_id = payload.get("document", {}).get("id")
            print_status(f"Created document '{document_name}' (ID: {created_id})", "success")
            return created_id
    
    print_status(f"Failed to create document. Response: {result}", "error")
    return None

def upload_sysml_content(document_id, sysml_content):
    """Upload SysML content to the document"""
    query = """
    mutation UploadDocument($input: UploadDocumentInput!) {
      uploadDocument(input: $input) {
        __typename
        ... on UploadDocumentSuccessPayload {
          document {
            id
            name
          }
        }
        ... on ErrorPayload {
          message
        }
      }
    }
    """
    
    variables = {
        "input": {
            "id": str(uuid.uuid4()),
            "documentId": document_id,
            "content": sysml_content
        }
    }
    
    result = query_graphql(query, variables)
    
    if result and "data" in result:
        payload = result["data"].get("uploadDocument", {})
        if payload.get("__typename") == "UploadDocumentSuccessPayload":
            print_status(f"Loaded SysML content into document", "success")
            return True
    
    print_status(f"Failed to upload SysML content. Response: {result}", "error")
    return False

def main():
    """Main execution"""
    print(f"\n{GREEN}=== Syson Project Loader ==={NC}\n")
    
    # Check Syson health
    print_status("Checking Syson availability...")
    if not check_syson_health():
        print_status("Syson is not responding. Make sure it's running.", "error")
        sys.exit(1)
    print_status("Syson is running", "success")
    
    # Check SysML file exists
    if not os.path.exists(SYSML_FILE):
        print_status(f"SysML file not found: {SYSML_FILE}", "error")
        sys.exit(1)
    print_status(f"Found SysML file: {SYSML_FILE}", "success")
    
    # Read SysML content
    print_status("Reading SysML content...")
    try:
        with open(SYSML_FILE, 'r') as f:
            sysml_content = f.read()
        print_status(f"Loaded {len(sysml_content)} bytes of SysML content", "success")
    except Exception as e:
        print_status(f"Failed to read SysML file: {str(e)}", "error")
        sys.exit(1)
    
    # Create project
    print_status(f"Creating project '{PROJECT_NAME}'...")
    project_id = create_project()
    if not project_id:
        sys.exit(1)
    
    # Create document
    print_status(f"Creating document...")
    doc_id = create_document(project_id, "AlpsRescueDroneModel.sysml")
    if not doc_id:
        sys.exit(1)
    
    # Upload SysML content
    print_status(f"Uploading SysML content...")
    if upload_sysml_content(doc_id, sysml_content):
        print_status(f"Project ready!", "success")
        print(f"\n{GREEN}Next steps:{NC}")
        print(f"1. Open Syson at {SYSON_URL}")
        print(f"2. Look for project '{PROJECT_NAME}'")
        print(f"3. View the document 'AlpsRescueDroneModel.sysml'\n")
    else:
        print_status("Failed to upload content. You may need to manually import via the web interface.", "error")

if __name__ == "__main__":
    main()

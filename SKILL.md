---
name: mulesoft-demo-builder
description: Create comprehensive MuleSoft integration demos with RAML specs, Exchange connectors, metadata, and interactive web pages
---

# MuleSoft Demo Builder

You are an expert at creating impressive, working MuleSoft integration demos that showcase real-world scenarios with drag-and-drop simplicity.

## Demo Philosophy: "No Vibes, Just Drag & Drop"

The goal is to create demos that:
- Use **Exchange connectors** (not generic HTTP requests) to showcase the connector catalog
- Enable **full drag-and-drop mapping** with metadata for visual development
- Have **realistic mock data** that tells a story
- Include **interactive web pages** for live demonstration
- Keep **DataWeave transforms clean and simple**
- Work **end-to-end with live API calls**

## Step-by-Step Demo Creation Process

### Phase 1: Planning & Design (5-10 minutes)

1. **Understand the Scenario**
   - Ask the user about their demo scenario (e.g., "employee lifecycle automation")
   - Identify the key systems to integrate (typically 3 systems works well)
   - Define the main flows (e.g., onboarding, offboarding)
   - Identify the customer/audience for branding

2. **Map the Integration Pattern**
   - **Pattern Example**: Candidate → Employee → Payroll → Badge Access
   - System 1: Source system (HR/ATS like Neogov)
   - System 2: Core system (ERP like NetSuite)
   - System 3: Downstream system (Scheduling like TeleStaff)
   - Each flow should call all 3 systems in sequence

3. **Define Realistic Test Data**
   - Use customer-specific data if available (employee names, locations, dept names)
   - Create 2-3 example records with complete details
   - Ensure IDs are traceable across systems (e.g., "CAND-99384" → "EMP-1008" → "NS-EMP-8815")

### Phase 2: RAML API Specifications (15-20 minutes)

Create separate RAML 1.0 specs for each system:

**Structure for Each RAML:**
```raml
#%RAML 1.0
title: [System Name] System API
version: v1
baseUri: https://api.[system].com/v1

description: |
  [System] API for [Customer Name].
  [Brief description of what this system manages]

types:
  RequestType:
    type: object
    properties:
      field1: string
      field2: string
    example:
      field1: "realistic-value"
      field2: "realistic-value"

  ResponseType:
    type: object
    properties:
      systemId: string
      status: string
      message: string
    example:
      systemId: "SYS-ID-123"
      status: "SUCCESS"
      message: "Descriptive success message"

/resource:
  post:
    description: Create/update resource
    body:
      application/json:
        type: RequestType
    responses:
      201:
        body:
          application/json:
            type: ResponseType
```

**Key Principles:**
- Include **3-5 realistic example records** in each RAML
- Use **customer terminology** (department names, locations, job titles)
- Make IDs **traceable** between systems
- Include **timestamps** in ISO format
- Add **descriptive messages** in responses
- Keep it **simple** - only include fields needed for the demo

**Publish to Exchange:**
- User must publish each RAML to Exchange to get mock endpoints
- Document the mock URLs for each API

### Phase 3: MuleSoft Project Setup (10 minutes)

1. **Create New Mule Project**
   ```
   Ask user to create project: [customer-name]-[demo-name]-demo
   Example: psf-employee-demo
   ```

2. **Add Exchange Connector Dependencies**
   ```xml
   <dependency>
       <groupId>[org-id]</groupId>
       <artifactId>mule-plugin-[system-name]-sapi</artifactId>
       <version>[version]</version>
       <classifier>mule-plugin</classifier>
   </dependency>
   ```
   - Add one dependency for each system
   - Get these from Exchange after publishing RAMLs

3. **Configure HTTP Listener**
   - Port: 8081
   - Paths: `/onboard`, `/offboard`, `/[operation]`
   - Add CORS headers for browser access

### Phase 4: Flow Implementation (20-30 minutes)

**Main Flow Structure:**
```
HTTP Listener
  ↓
Store Request (with metadata)
  ↓
Transform → Connector Call → Store Result (System 1)
  ↓
Transform → Connector Call → Store Result (System 2)
  ↓
Transform → Connector Call → Store Result (System 3)
  ↓
Build Final Response
```

**Implementation Guidelines:**

1. **Use Exchange Connectors (NOT HTTP Request)**
   ```xml
   <!-- ✅ CORRECT: Exchange Connector -->
   <system-api:create-resource 
       config-ref="System_Config" />
   
   <!-- ❌ WRONG: Generic HTTP -->
   <http:request config-ref="HTTP_Config" path="/resource" />
   ```

2. **Configure Connectors with Mock URLs**
   ```xml
   <system-api:config name="System_Config">
       <system-api:connection 
           property_host="anypoint.mulesoft.com"
           property_port="443"
           property_basePath="/mocking/api/v1/links/[link-id]/v1"
           property_protocol="HTTPS" />
   </system-api:config>
   ```

3. **Store Variables Using Transforms**
   ```xml
   <ee:transform doc:name="Store [System] Result">
       <ee:message />
       <ee:variables>
           <ee:set-variable variableName="[system]Result"><![CDATA[%dw 2.0
   output application/json
   ---
   payload]]></ee:set-variable>
       </ee:variables>
   </ee:transform>
   ```

4. **Keep DataWeave Simple - NO inline types**
   ```dataweave
   %dw 2.0
   output application/json
   ---
   {
       field1: vars.request.field1,
       field2: vars.request.field2
   }
   ```
   - Don't add `type` definitions in DataWeave
   - Don't add `as TypeName` casting
   - Keep transforms clean and readable

5. **Add CORS Support**
   ```xml
   <http:listener path="/[resource]" allowedMethods="POST">
       <http:response>
           <http:headers><![CDATA[#[{
               'Access-Control-Allow-Origin': '*',
               'Access-Control-Allow-Methods': 'POST, OPTIONS',
               'Access-Control-Allow-Headers': 'Content-Type, Accept'
           }]]]></http:headers>
       </http:response>
   </http:listener>
   
   <!-- OPTIONS handler for preflight -->
   <flow name="options-handler-flow">
       <http:listener path="/*" allowedMethods="OPTIONS">
           <http:response statusCode="200">
               <http:headers><![CDATA[#[{
                   'Access-Control-Allow-Origin': '*',
                   'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                   'Access-Control-Allow-Headers': 'Content-Type, Accept, Authorization',
                   'Access-Control-Max-Age': '3600'
               }]]]></http:headers>
           </http:response>
       </http:listener>
       <set-payload value='{"status":"OK"}' mimeType="application/json"/>
   </flow>
   ```

### Phase 5: Metadata Setup (20-30 minutes)

**Create Metadata JSON Files:**

1. **Create Directory**
   ```
   src/main/resources/metadata/
   ```

2. **Create JSON Example for Each Type**
   - Request types (e.g., `OnboardRequest.json`)
   - Response types (e.g., `System1Response.json`)
   - One file per request/response in the flow
   - Use **realistic data** from RAML examples

3. **Create Metadata Guides**
   - `METADATA-CHECKLIST.md` - Simple checkbox list
   - `METADATA-PAYLOAD-GUIDE.md` - Detailed instructions
   - `METADATA-VISUAL-MAP.md` - Flow diagram showing metadata placement

**Metadata Definition Pattern:**
```
For each transform:
  Input Side:
    - Payload metadata (if reading from connector/listener)
    - Variable metadata (for vars.request, vars.system1Result, etc.)
  Output Side:
    - Payload metadata (if sending to connector)
    - Variable metadata (if storing result)
```

**Instructions for User:**
1. Open transform in Studio
2. Click "Payload" or variable name in Input/Output panel
3. Click "Define Metadata" → "Add" → "JSON"
4. Browse to corresponding JSON file
5. Click "Select"

### Phase 6: Interactive Demo Webpage (30-40 minutes)

**Create `demo-page.html` with:**

1. **Customer Branding**
   - Use customer logo (from their website)
   - Use customer brand colors
   - Include customer name throughout

2. **Visual Flow Representation**
   ```html
   <!-- Progress bar showing steps -->
   <!-- System cards with animations -->
   <!-- Real-time status updates -->
   ```

3. **Live API Calls**
   ```javascript
   async function runOnboarding() {
       const response = await fetch('http://localhost:8081/onboard', {
           method: 'POST',
           headers: { 'Content-Type': 'application/json' },
           body: JSON.stringify(employeeData)
       });
       const result = await response.json();
       // Update UI with results
   }
   ```

4. **Demo Features**
   - Step-by-step progress visualization
   - System cards that light up as each call completes
   - Display of actual response data
   - Success/error handling with visual feedback
   - Reset button to run demo again

5. **Serve via Python HTTP Server**
   ```bash
   python3 -m http.server 8000
   # Access: http://localhost:8000/demo-page.html
   ```

**Key HTML/CSS Patterns:**
- Use CSS custom properties for brand colors
- Animate system cards with transitions
- Show data flow with visual arrows/connections
- Display JSON responses in formatted code blocks
- Mobile-responsive design

### Phase 7: Testing & Documentation (15-20 minutes)

1. **Test with cURL**
   ```bash
   curl -X POST http://localhost:8081/[endpoint] \
     -H "Content-Type: application/json" \
     -d '{ "field": "value" }'
   ```

2. **Test with Browser**
   - Open demo page
   - Click through all flows
   - Verify data appears correctly
   - Check browser console for errors

3. **Create README.md**
   ```markdown
   # [Customer] [Demo Name]
   
   ## Architecture
   [Diagram of 3-system integration]
   
   ## Running the Demo
   1. Start MuleSoft app
   2. python3 -m http.server 8000
   3. Open http://localhost:8000/demo-page.html
   
   ## Testing
   [cURL examples for each endpoint]
   
   ## Talking Points
   - Exchange connectors showcase
   - Drag-and-drop mapping
   - [Customer-specific value props]
   ```

## Common Patterns & Best Practices

### Three-System Integration Pattern
**Works for most B2B/enterprise scenarios:**
1. **System 1**: Source/Trigger (HR, CRM, Order System)
2. **System 2**: Core/Master (ERP, Database, Master Data)
3. **System 3**: Downstream/Action (Scheduling, Billing, Fulfillment)

**Example Scenarios:**
- Employee Onboarding: HR → ERP → Badge/Access System
- Order Processing: E-commerce → ERP → Warehouse Management
- Customer Onboarding: CRM → Billing → Support System
- Claims Processing: Claims System → Core System → Payment System

### Metadata File Naming Convention
```
[FlowName][SystemName][RequestOrResponse].json

Examples:
- OnboardRequest.json (initial request)
- NeogovExportResponse.json (system response)
- OffboardRequest.json (offboarding request)
```

### DataWeave Transform Naming
```
- "Store Request with Metadata" (captures input)
- "Prepare [System] Request" (maps data for connector)
- "Store [System] Result" (captures response)
- "Build Success Response" (final output)
```

### Documentation Files to Create
1. `README.md` - Main demo instructions
2. `METADATA-CHECKLIST.md` - Step-by-step metadata setup
3. `METADATA-PAYLOAD-GUIDE.md` - Detailed payload metadata guide
4. `METADATA-VISUAL-MAP.md` - Visual flow diagram
5. `demo-page.html` - Interactive demo webpage

## Troubleshooting Common Issues

### Issue: CORS Errors in Browser
**Solution:** 
- Add CORS headers directly to HTTP listener response
- Create separate OPTIONS handler flow
- Serve HTML via HTTP server (not file://)

### Issue: Metadata Not Showing in Studio
**Solution:**
- Verify JSON files are in `src/main/resources/metadata/`
- Check JSON is valid (use jsonlint)
- Define payload metadata BEFORE variable metadata
- Restart Studio if needed

### Issue: Connector Not Found
**Solution:**
- Verify Exchange connector is published
- Check pom.xml has correct groupId/artifactId/version
- Look at connector module XML to find correct operation names
- Check namespace declarations in mule XML

### Issue: Mock Endpoint 404
**Solution:**
- Add `/v1` to path (Exchange includes baseUri in path)
- Verify mock link ID is correct
- Check RAML is published and mocking is enabled

## Demo Timing Guidelines

**Quick Demo (15 minutes):**
- 1 flow (onboarding only)
- 3 systems
- Basic webpage
- Pre-configured metadata

**Standard Demo (30 minutes):**
- 2 flows (onboarding + offboarding)
- 3 systems
- Interactive webpage with animations
- Full metadata setup shown

**Comprehensive Demo (45-60 minutes):**
- Multiple flows
- 3-4 systems
- Advanced webpage features
- Live metadata configuration
- Code walkthrough

## Value Propositions to Highlight

1. **Exchange Connector Catalog**: "Hundreds of pre-built connectors, just drag and drop"
2. **Visual Development**: "No coding required, map fields visually"
3. **Metadata-Driven**: "Define once, reuse everywhere with autocomplete"
4. **API-Led Connectivity**: "System APIs provide reusable interfaces"
5. **Rapid Integration**: "Built in hours, not weeks"

## When User Asks for Demo Creation

1. **Ask clarifying questions:**
   - "What's the integration scenario?" (employee lifecycle, order processing, etc.)
   - "Which systems are involved?" (get 3 system names)
   - "Who is the customer/audience?" (for branding)
   - "What's the business outcome?" (for messaging)

2. **Start with Phase 1 (Planning)**
   - Map out the 3-system flow
   - Define realistic test data
   - Get customer branding assets

3. **Work through phases sequentially**
   - Create RAMLs → Publish to Exchange → Build flows → Add metadata → Create webpage

4. **Provide comprehensive documentation**
   - Metadata setup guides
   - README with testing instructions
   - Talking points document

5. **Test end-to-end before completing**
   - cURL tests for all endpoints
   - Browser tests via demo page
   - Verify all metadata is working

## Success Criteria

A successful demo has:
- ✅ All 3 systems integrated with Exchange connectors (not HTTP)
- ✅ Clean DataWeave with no inline types
- ✅ Full metadata configured for drag-and-drop
- ✅ Interactive webpage with customer branding
- ✅ Realistic mock data that tells a story
- ✅ Working end-to-end with live API calls
- ✅ Comprehensive documentation for setup
- ✅ CORS configured for browser access
- ✅ Clear talking points for presenter

## Remember

The goal is **simplicity and visual demonstration**. Every choice should make the demo:
- Easier to understand
- More visual and interactive
- Faster to build
- More impressive to watch

"No Vibes, Just Drag & Drop" - make integration look easy!

## Clean room creation + listing publish (Console steps)

This part is easiest in the Console because the UI walks you through:

- creating the **data clean room**
- adding **contributors** and **subscribers**
- adding data as a **listing**
- choosing **analysis rules**
- verifying **data egress controls**

### 1) Create the clean room (in CLEANROOM_PROJECT_ID)

- Open BigQuery → **Sharing (Analytics Hub)**
- Create **Data clean room**
- Use a clear name: `poc_user_events_clean_room`

### 2) Add members

- **Data contributor**: the producer identity you’ll use to publish (user or service account)
- **Subscriber**: the consumer identity (user or service account)

### 3) Add data (create a listing)

On the contributor side, add a listing referencing:

- `PRODUCER_PROJECT_ID.producer_shared.user_events_view`

### 4) Configure analysis rules

For this POC, choose an **aggregation-threshold analysis rule** so:

- raw row output is prevented
- consumer must query with allowed syntax (see the clean room docs section “Query data in a linked dataset”)

### 5) Ensure restricted egress is on (POC-critical)

You want to validate the “blocked actions” behavior, so ensure the clean room/listing is configured such that the consumer’s linked dataset is **restricted egress** (publisher-configured).

The Analytics Hub docs state that when restricted:

- copy/clone/export/snapshot APIs and UI are disabled
- CTAS / writing results to destination tables/views are disabled

### 6) Consumer subscribes

In the consumer project:

- subscribe to the clean room
- confirm the **linked dataset** is created



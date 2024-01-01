# Program structure

## User to Teiserver
The expectation is your users will have an application running on their machine, this application will connect to your endpoint (websocket, grpc, plaintext etc). Your endpoint will be an Elixir application running Teiserver as a dependency and making the calls to it.

```mermaid
graph TD;
    app[User application] <--> Endpoint;
    Endpoint --> CommandIn[Command dispatch];
    CommandIn --> HandleIn[Command handler];
    HandleIn --> Teiserver;
    Teiserver --> HandleOut[Response handler];
    HandleOut --> Endpoint;
```


## Endpoint information flow
The endpoints are can communicate with users however you want. In terms of Teiserver they are expected to make function calls to Teiserver context modules and receive information via return values and also process messages (typically via Pubsubs).

```mermaid
sequenceDiagram
    actor User
    participant Endpoint
    participant Teiserver
    
    Note right of User: User event
    User->>Endpoint: Message/Command
    Endpoint->>Teiserver: Function call
    Teiserver->>Endpoint: Return value
    Endpoint->>User: Message/Command
    
    Note right of User: Server event
    Teiserver->>Endpoint: Pubsub message
    Endpoint->>User: Message/Command
```

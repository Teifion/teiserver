# Program structure

## User to Teiserver
The expectation is your users will have an application running on their machine, this application will connect to your endpoint (websocket, grpc, plaintext etc). Your endpoint will be an Elixir application running Teiserver as a dependency and making the calls to it.

```mermaid
graph TD;
    app[User application] <--> Endpoint;
    Endpoint --> CommandIn[Command handler];
    CommandIn --> Teiserver[Teiserver library];
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

## Login through to playing a game
The expected flow of events for a user logging into your application and playing a game is expected to look something like this. Note depending on protocols and features you may end up with slightly different steps.

```mermaid
sequenceDiagram
    actor User
    participant Server
    participant Game
    
    Game->>+Server: Login
    Server->>Game: Accept login
    Game->>Server: Open lobby
    
    User->>Server: Login
    Server->>User: Accept login
    Server->>User: Send client info
    
    User->>Server: Request lobby list
    Server->>User: Send lobby list
    
    User->>Server: Join lobby
    Server->>Game: User joined
    Game->>Server: Start match
    Server->>-User: Start match
    
    Note right of Server: Server not needed now
    
    User->>Game: Match events
    Game->>User: Match events
    User->>Game: Match events
    Game->>User: Match events
    
    Game->>+Server: Match ended
    
    Note right of Server: Server becomes relevant
    
    User->>Server: Update client state
    User->>Server: Leave lobby
    Server->>-Game: User left
```
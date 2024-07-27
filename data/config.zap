
opt server_output = "../src/server/Modules/Data/ServerEvents.luau"
opt client_output = "../src/modules/Data/Events.luau"

event CreateHint = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        Hint: string,
        Color: unknown,
        Duration: string?
    }
}
event ChangeMusic = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        MusicId: string,
        Volume: string?,
        StartTick: string?
    }
}
event ChangeLighting = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Properties: unknown,
        PostEffects: unknown
    }
}
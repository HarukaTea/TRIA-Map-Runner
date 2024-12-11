
opt client_output = "../src/shared/Library/Events.luau"
opt server_output = "../src/server/Modules/Library/ServerEvents.luau"
opt remote_scope = "HARUKA"

event CreateHint = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        Hint: string?,
        Color: unknown,
        Duration: string?
    }
}
event ChangeMusic = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        MusicId: string?,
        Volume: string?,
        StartTick: string?
    }
}
event ChangeLighting = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Properties: map {
            [string]: unknown
        }?,
        PostEffects: map {
            [string]: map {
                [string]: unknown
            }?
        }?
    }
}
event TeleportPlayer = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Player: Instance (Player)?,
        Destination: CFrame?,
        FaceFront: boolean?
    }
}
event ForceReset = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {}
}
event MapRoundEnding = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {}
}
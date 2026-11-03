export type LuaState = number;
export type EnvironmentVariables = Record<string, string | undefined>;
export declare enum LuaReturn {
    Ok = 0,
    Yield = 1,
    ErrorRun = 2,
    ErrorSyntax = 3,
    ErrorMem = 4,
    ErrorErr = 5,
    ErrorFile = 6
}
export interface LuaResumeResult {
    result: LuaReturn;
    resultCount: number;
}
export interface LuaThreadRunOptions {
    timeout?: number;
}
export declare const PointerSize = 4;
export declare const LUA_MULTRET = -1;
export declare const LUAI_MAXSTACK = 1000000;
export declare const LUA_REGISTRYINDEX: number;
export declare enum LuaType {
    None = -1,
    Nil = 0,
    Boolean = 1,
    LightUserdata = 2,
    Number = 3,
    String = 4,
    Table = 5,
    Function = 6,
    Userdata = 7,
    Thread = 8
}
export declare enum LuaEventCodes {
    Call = 0,
    Ret = 1,
    Line = 2,
    Count = 3,
    TailCall = 4
}
export declare enum LuaEventMasks {
    Call = 1,
    Ret = 2,
    Line = 4,
    Count = 8
}
export declare enum LuaLibraries {
    Base = "_G",
    Coroutine = "coroutine",
    Table = "table",
    IO = "io",
    OS = "os",
    String = "string",
    UTF8 = "utf8",
    Math = "math",
    Debug = "debug",
    Package = "package"
}
export declare class LuaTimeoutError extends Error {
}

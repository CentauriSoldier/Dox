import { LuaResumeResult, LuaReturn, LuaState, LuaThreadRunOptions, LuaType } from './types';
import { Pointer } from './pointer';
import LuaTypeExtension from './type-extension';
import MultiReturn from './multireturn';
import type LuaWasm from './luawasm';
export interface OrderedExtension {
    priority: number;
    extension: LuaTypeExtension<unknown>;
}
export default class Thread {
    readonly address: LuaState;
    readonly lua: LuaWasm;
    protected readonly typeExtensions: OrderedExtension[];
    private closed;
    private hookFunctionPointer;
    private timeout?;
    private readonly parent?;
    constructor(lua: LuaWasm, typeExtensions: OrderedExtension[], address: number, parent?: Thread);
    newThread(): Thread;
    resetThread(): void;
    loadString(luaCode: string, name?: string): void;
    loadFile(filename: string): void;
    resume(argCount?: number): LuaResumeResult;
    getTop(): number;
    setTop(index: number): void;
    remove(index: number): void;
    setField(index: number, name: string, value: unknown): void;
    run(argCount?: number, options?: Partial<LuaThreadRunOptions>): Promise<MultiReturn>;
    runSync(argCount?: number): MultiReturn;
    pop(count?: number): void;
    call(name: string, ...args: any[]): MultiReturn;
    getStackValues(start?: number): MultiReturn;
    stateToThread(L: LuaState): Thread;
    pushValue(rawValue: unknown, userdata?: unknown): void;
    setMetatable(index: number, metatable: Record<any, any>): void;
    getMetatableName(index: number): string | undefined;
    getValue(index: number, inputType?: LuaType, userdata?: unknown): any;
    close(): void;
    setTimeout(timeout: number | undefined): void;
    getTimeout(): number | undefined;
    getPointer(index: number): Pointer;
    isClosed(): boolean;
    indexToString(index: number): string;
    dumpStack(log?: {
        (...data: any[]): void;
        (message?: any, ...optionalParams: any[]): void;
    }): void;
    assertOk(result: LuaReturn): void;
    private getValueDecorations;
}

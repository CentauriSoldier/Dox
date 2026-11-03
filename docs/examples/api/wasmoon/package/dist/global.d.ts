import { LuaLibraries } from './types';
import LuaTypeExtension from './type-extension';
import Thread from './thread';
import type LuaWasm from './luawasm';
export default class Global extends Thread {
    private memoryStats;
    private allocatorFunctionPointer;
    constructor(cmodule: LuaWasm, shouldTraceAllocations: boolean);
    close(): void;
    registerTypeExtension(priority: number, extension: LuaTypeExtension<unknown>): void;
    loadLibrary(library: LuaLibraries): void;
    get(name: string): any;
    set(name: string, value: unknown): void;
    getTable(name: string, callback: (index: number) => void): void;
    getMemoryUsed(): number;
    getMemoryMax(): number | undefined;
    setMemoryMax(max: number | undefined): void;
    private getMemoryStatsRef;
}

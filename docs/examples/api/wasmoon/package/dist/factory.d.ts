import { EnvironmentVariables } from './types';
import LuaEngine from './engine';
import LuaWasm from './luawasm';
export default class LuaFactory {
    private luaWasmPromise;
    constructor(customWasmUri?: string, environmentVariables?: EnvironmentVariables);
    mountFile(path: string, content: string | ArrayBufferView): Promise<void>;
    mountFileSync(luaWasm: LuaWasm, path: string, content: string | ArrayBufferView): void;
    createEngine(options?: ConstructorParameters<typeof LuaEngine>[1]): Promise<LuaEngine>;
    getLuaModule(): Promise<LuaWasm>;
}

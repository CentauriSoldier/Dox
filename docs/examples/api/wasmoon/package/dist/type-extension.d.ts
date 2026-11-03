import { BaseDecorationOptions, Decoration } from './decoration';
import { LuaType } from './types';
import Global from './global';
import Thread from './thread';
export default abstract class LuaTypeExtension<T, K extends BaseDecorationOptions = BaseDecorationOptions> {
    readonly name: string;
    protected thread: Global;
    constructor(thread: Global, name: string);
    isType(_thread: Thread, _index: number, type: LuaType, name?: string): boolean;
    abstract close(): void;
    getValue(thread: Thread, index: number, _userdata?: unknown): T;
    pushValue(thread: Thread, decoratedValue: Decoration<T, K>, _userdata?: unknown): boolean;
}

export interface BaseDecorationOptions {
    metatable?: Record<any, any>;
}
export declare class Decoration<T = any, K extends BaseDecorationOptions = BaseDecorationOptions> {
    target: T;
    options: K;
    constructor(target: T, options: K);
}
export declare function decorate<T extends BaseDecorationOptions = BaseDecorationOptions>(target: unknown, options: T): Decoration<any, T>;

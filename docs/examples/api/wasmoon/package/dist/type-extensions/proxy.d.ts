import { BaseDecorationOptions, Decoration } from '../decoration';
import Global from '../global';
import TypeExtension from '../type-extension';
export interface ProxyDecorationOptions extends BaseDecorationOptions {
    proxy?: boolean;
}
export declare function decorateProxy(target: unknown, options?: ProxyDecorationOptions): Decoration<any, ProxyDecorationOptions>;
export default function createTypeExtension(thread: Global): TypeExtension<any, ProxyDecorationOptions>;

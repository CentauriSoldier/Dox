import { BaseDecorationOptions, Decoration } from '../decoration';
import Global from '../global';
import TypeExtension from '../type-extension';
export interface UserdataDecorationOptions extends BaseDecorationOptions {
    reference?: boolean;
}
export declare function decorateUserdata(target: unknown): Decoration<any, UserdataDecorationOptions>;
export default function createTypeExtension(thread: Global): TypeExtension<Error>;

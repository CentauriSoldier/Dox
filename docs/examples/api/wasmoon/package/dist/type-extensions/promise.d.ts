import Global from '../global';
import TypeExtension from '../type-extension';
export default function createTypeExtension<T = unknown>(thread: Global, injectObject: boolean): TypeExtension<Promise<T>>;

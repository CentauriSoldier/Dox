import Global from '../global';
import TypeExtension from '../type-extension';
export type TableType = Record<any, any> | any[];
export default function createTypeExtension(thread: Global): TypeExtension<any>;

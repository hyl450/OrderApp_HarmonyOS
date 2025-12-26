// types.ts
// 或者使用更严格的定义
export type SerializablePrimitive = string | number | boolean | null | undefined;
export type SerializableArray = Serializable[];
export type SerializableMap = Map<string, Serializable>;
export type Serializable = SerializablePrimitive | SerializableArray | SerializableMap;
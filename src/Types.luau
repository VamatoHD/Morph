--!strict

export type Id = string | number

export type State = {
	Id: Id,
	Info: TweenInfo?,
	Goal: { [string]: any },
}

export type Animation = {
	Object: Instance,
	_isRunning: boolean,
	_isPaused: boolean,
	_Conn: RBXScriptConnection?,
	_States: { [Id]: State },
	_Current: Id?,
	_Tween: Tween?,
	_FinishBinds: { [Animator]: BindParams },
}

export type BindParams = {
	Other: Animator,
	Id: Id?, -- If id is nil, pass the played id
	Callback: ((Instance) -> nil)?,
	ForcePlay: boolean?,
}

export type PlayFunction = (self: Animator, Id: Id?, Callback: ((Instance) -> nil)?) -> Animator

export type Animator = typeof(setmetatable({} :: Animation, {} :: AnimatorImpl))

export type AnimatorImpl = {
	__index: AnimatorImpl,
	new: (Object: Instance) -> Animator,
	AddState: (self: Animator, value: State) -> Animator,
	Stop: (self: Animator) -> Animator,
	Pause: (self: Animator) -> Animator,
	Resume: (self: Animator) -> Animator,
	ForcePlay: PlayFunction,
	Play: PlayFunction,
	Wait: (self: Animator, Time: number) -> Animator,
	BindToFinish: (self: Animator, value: BindParams) -> Animator,
	UnBind: (self: Animator, Other: Animator) -> Animator,
}

export type Morph = {
	new: (Object: Instance) -> Animator,
}

return nil

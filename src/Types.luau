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
}

export type Animator = typeof(setmetatable({} :: Animation, {} :: AnimatorImpl))

export type AnimatorImpl = {
	__index: AnimatorImpl,
	new: (Object: Instance) -> Animator,
	AddState: (self: Animator, value: State) -> Animator,
	Stop: (self: Animator) -> Animator,
	Pause: (self: Animator) -> Animator,
	Resume: (self: Animator) -> Animator,
	ForcePlay: (self: Animator, Id: Id?, Callback: ((Instance) -> nil)?) -> Animator,
	Play: (self: Animator, Id: Id?, Callback: ((Instance) -> nil)?) -> Animator,
	Wait: (self: Animator, Time: number) -> Animator,
}

export type Morph = {
	new: (Object: Instance) -> Animator,
}

return nil

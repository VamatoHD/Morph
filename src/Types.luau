--!strict

export type Id = string | number

export type State = {
	Id: Id,
	Info: TweenInfo?,
	Goal: { [string]: any },
}

export type Animation = {
	Object: Instance,
	PlaybackState: Enum.PlaybackState,
	_Conn: RBXScriptConnection?,
	_States: { [Id]: State },
	_Current: Id?,
	_Tweens: { [Id]: Tween },
	_FinishBinds: { [Animator]: BindParams },
}

export type BindParams = {
	Other: Animator,
	Id: Id?, -- If id is nil, pass the played id
	Callback: ((Animator) -> nil)?,
	ForcePlay: boolean?,
}

export type PlayFunction = (self: Animator, Id: Id?, Callback: ((Animator) -> nil)?) -> Animator

export type Animator = typeof(setmetatable({} :: Animation, {} :: AnimatorImpl))

export type AnimatorImpl = {
	__index: AnimatorImpl,
	new: (Object: Instance) -> Animator,
	AddState: (self: Animator, value: State) -> Animator,
	Cancel: (self: Animator) -> Animator,
	Pause: (self: Animator) -> Animator,
	ForcePlay: PlayFunction,
	Play: PlayFunction,
	Wait: (self: Animator, Time: number) -> Animator,
	BindToFinish: (self: Animator, value: BindParams) -> Animator,
	UnBind: (self: Animator, Other: Animator) -> Animator,
	--helper functions
	_stop: (self: Animator) -> Animator,
	_getTween: (self: Animator, Id: Id?) -> Tween,
}

export type Morph = {
	new: (Object: Instance) -> Animator,
}

return nil

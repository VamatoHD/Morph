<img src="assets/Logo.png">

Morph is a powerful TweenService wrapper module designed to simplify the management of tweens in Roblox.

When dealing with a large number of tweens, Roblox's TweenService requires individual variables for each Tween, which can become difficult to manage. 
<br>
Morph addresses this issue by providing a container for states, streamlining the process and making your code cleaner and more organized.

### Features
- State Management: Add and manage multiple tweens within a single container.
- Easy Integration: Includes every tween function for easy mgration.

## Instalation

1. Head to [releases](https://github.com/VamatoHD/Morph/releases)
2. Download the latest version Morph.rbxm file
3. Insert it into your game
4. You are ready to use it!!

## Example

```lua
local Animator = Morph.new(part)
    :AddState {
        Id = "Id1",
        Info = TweenInfo.new(2),
        Goal = {
            Position = Vector3.zero
        }
    }

Animator:Play("Id1")

task.wait(1)
Animator:Pause()

--Resume animation
Animator:Play()
--Cancel animation
Animator:Cancel()

```

## License

Morph is licensed freely under MIT. Use it as you want, and if you feel like it, give me a shoutout!

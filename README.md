A simple state machine first person controller asset made in Godot 4

# **General**


This asset provides a simple, fully commented, finite state machine based controller, camera, as well as a properties HUD

A test map is provided to test the controller.

The controller use a finite state machine, designed to be easely editable, allowing to easily add, remove and modify behaviours and actions.

Each state has his own script, allowing to easly filter and manage the communication between each state.

He is also very customizable, with a whole set of open variables for every state and for more general stuff. This is the same for the camera.

The asset is 100% written in GDScript.

He works on Godot 4.4, 4.3, and 4.2. I didn't test it in Godot 4.1 and Godot 4.0, but it should work just fine.

The video showcasing the asset features : 


# **Features**

 - Smooth moving
 - Ability to move on slopes and hills
 - Walking
 - Crouching (continious and once pressed input)
 - Running (continious and once pressed input)
 - Jumping (multiple jump system)
 - Jump buffering
 - Coyote jump/time
 - Air control (easely customizable thanks to curves)
 - Bunny hopping (+ auto bunny hop)
    
 - Camera tilt
 - Camera bob
 - Custom smooth FOV
   
 - Reticle
 - Properties HUD


# **Controls**


All keys bindings can be modified

- W, S, A, D (alternatively : up, down, left, right) = move
- Space = jump
- Left shift = run
- C = crouch
- Ctrl = mouse mode


# **Purpose**


At start, i just wanted to rework my FPS controller template, make an alternate version of it, closer to the finite state machine approach.
But while i was working on it, i said to myself "why not share it with the community, when it's ready ?".
And so here we go !


# **How to use**


It's an asset, which means you can add it to an existing project without any issue.
Simply download it, add it to your project, and get the files you want to use, that's all.


# **Requets**

For any bug request, please write on down in the "issues" section.
For any new feature/improvement request, please write it down in the "discussions" section.




 

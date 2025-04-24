🧍‍♂️ 3D Game Character Movement: Physics Model Documentation
📌 Overview
This document defines the physical movement attributes and mechanics of a Player Character (PC) in a 3D game environment. It covers kinematics, collision behavior, state-based movement, and realistic physics simulation, serving as a guideline for implementing and tuning a polished, high-quality character controller.

⚙️ Physics Constants

Attribute	Value	Description
GRAVITY	-9.81 m/s²	Acceleration due to gravity
GROUND_FRICTION	8.0	Applied when on ground
AIR_FRICTION	0.5	Applied in air
SPLIT_FRICTION	X=5, Z=3	Independent friction in local axes
PLAYER_HEIGHT	1.8m	Standing height
CROUCH_HEIGHT	1.0m	Height when crouched
STEP_OFFSET	0.45m	Height the player can step onto
CAPSULE_RADIUS	0.3m	For character collider
🧭 Movement States & Base Speeds

State	Max Speed (m/s)	Acceleration (m/s²)	Deceleration (m/s²)
Walk	3.0	8.0	10.0
Sprint	6.5	12.0	10.0
Crouch	1.5	6.0	6.0
Air	-	5.0 (limited)	5.0
Dash	12.0 (burst)	∞ (instant)	10.0
🏃 Movement Mechanics
✅ Directional Input Handling
Input Vector Normalization is crucial to fix diagonal movement problems:

ts
Copy
Edit
moveDirection = normalize(Vector2(inputX, inputZ))
Movement applies relative to the camera forward & right.

✅ Split Friction Application
Split friction resolves jittery/sticky movement on stairs/slopes.

Apply separate damping for X and Z velocity components to preserve sliding behavior on inclined surfaces:

python
Copy
Edit
velocity.x = lerp(velocity.x, 0, deltaTime * splitFriction.x)
velocity.z = lerp(velocity.z, 0, deltaTime * splitFriction.z)
🦘 Jumping System

Feature	Value
Jump Height	1.8m
Jump Force	7.5 m/s (initial)
Air Control	40% of ground control
✅ Double Jump
Available only once after leaving ground.

Resets if grounded again.

Uses separate force (6.5 m/s) to give slightly weaker second jump.

💨 Dash System

Attribute	Value
Dash Distance	7.0m
Dash Time	0.25s
Cooldown	1.5s
✅ Jump + Dash Combo Logic
If dash is triggered during jump, character:

Keeps vertical velocity

Propels horizontally in dash direction

Ensure character state transitions:

airborne → dash_air → airborne

🧎 Crouch System
Toggles collider height from 1.8m to 1.0m

Speed reduced

Automatically returns to stand if enough space detected via raycast

🏃‍♂️ Sprint System
Activated on hold input

Only works on ground and forward input

Disables jumping while sprinting for balance

Adds camera FOV boost (optional):

Default: 75°

Sprinting: 85°

🧮 Diagonal Movement Fix
Without normalization:

ts
Copy
Edit
velocity = moveX + moveZ // results in 1.41x speed
With normalization:

ts
Copy
Edit
inputVector = normalize(Vector2(inputX, inputZ))
Then apply to movement:

ts
Copy
Edit
velocity.x = inputVector.x * speed
velocity.z = inputVector.y * speed
🔄 State Machine Flow
plaintext
Copy
Edit
[Idle] 
 ├── Input(WASD) → [Walking]
 ├── Sprint Key + Forward → [Sprinting]
 ├── Crouch Key → [Crouching]
 ├── Jump Key → [Jumping]
 └── Dash Key → [Dashing]

[Jumping]
 ├── Jump Again → [DoubleJump]
 ├── Dash → [DashAir]
 └── Land → [Idle/Walking]

[Crouching]
 ├── No obstacle above → [Idle/Walking]
 └── Move → [CrouchWalking]

[Dash]
 └── Ends → [Previous State]
🧠 Advanced Concepts
✔️ Momentum Preservation
Airborne velocity preserves momentum unless acted upon.

No velocity reset on landing unless required for balance.

✔️ Velocity Clamping
Prevent unnatural movement accumulation:

ts
Copy
Edit
velocity = clampMagnitude(velocity, maxAllowedSpeed)
✔️ Slope Detection & Handling
Use raycast for ground angle

Prevent jumping/dashing on steep slopes (e.g., angle > 45°)

Add stick-to-ground force on small slopes to avoid sliding

🧪 Debugging Tips

Symptom	Possible Cause
Slide on stairs	Split friction not applied
Dash midair feels wrong	Velocity not retained
Too fast diagonal speed	Missing normalization
Jump feels floaty	Too low gravity or drag too high
Double jump reset not working	Ground detection too late
🧬 Tuning & Expansion
🔧 Possible Tweaks
Add variable jump height based on button hold duration.

Add coyote time (e.g., 0.2s) after leaving ground to still allow jump.

Introduce input buffering for responsive actions.

🔮 Future Extensions
Wall jump

Wall run

Slide mechanic while sprinting

Ladder or climb interactions
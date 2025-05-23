; tunnel explorer example

Graphics3D 640,480

; need a camera to see the world

camera=CreateCamera()

; need a light to create shading on surfaces

light=CreateLight()
RotateEntity light,30,-40,0

; create a cube in front of the camera

tunnel=CreateCylinder(20,False)
ScaleMesh tunnel,1,3,1
RotateEntity tunnel,90,0,0
FlipMesh tunnel
PositionEntity tunnel,0,0,5

; spin the cube until the escape key is hit

WireFrame True

While Not KeyHit(1)
;	f#=Sin(MilliSecs()*0.1)
;	TurnEntity cube,.1,2,3*f
	RenderWorld
	Flip
Wend


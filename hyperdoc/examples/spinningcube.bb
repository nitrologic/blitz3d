; spinning cube example

AppTitle "Spinning Cube"

Graphics3D 640,480

; need a camera to see the world

camera=CreateCamera()
CameraClsColor camera,255,255,255

; need a light to create shading on surfaces

light=CreateLight()
RotateEntity light,0,20,0
LightColor light,40,40,40

; create a cube in front of the camera

cube=CreateCube()
PositionEntity cube,0,0,5

FitMesh cube,-5,-5,-.5,10,10,1,True

; spin the cube until the escape key is hit

TurnEntity cube,-30,40,22

While Not KeyHit(1)
	f#=Sin(MilliSecs()*0.1)
	TurnEntity cube,.1,2,3*f
	RenderWorld
	Flip
Wend
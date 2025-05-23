; mousepick example

Graphics3D 640,480
CreateLight()

CreateMirror

camera=CreateCamera()
PositionEntity camera,0,0,-40

Collisions 1,1,1,1

For i=1 To 50
	ball=CreateSphere()
	PositionEntity ball,Rand(-10,10),Rand(-10,10),0
	EntityPickMode ball,1
	EntityRadius ball,15
	UpdateWorld
Next


; let user drag objects with mouse until escape key hit

While Not KeyHit(1)
	CameraPick(camera,MouseX(),MouseY())
	ball=PickedEntity()
	If ball
		dx#=PickedX()-EntityX(ball)
		dy#=PickedY()-EntityY(ball)
		MoveEntity ball,dx,dy,0
		PointEntity  camera,ball
	EndIf
	UpdateWorld
	RenderWorld
	Flip
Wend
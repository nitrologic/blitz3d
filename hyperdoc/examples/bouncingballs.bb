; bouncing balls example

Graphics3D 640,480
CreateLight()

camera=CreateCamera()
PositionEntity camera,0,2,0
CameraClsColor camera,20,80,200

CameraFogMode camera,1
CameraFogRange camera,6,32
CameraFogColor camera,0,255,0

plane=CreatePlane()
EntityType plane,1
EntityColor plane,120,220,120

; create a collection of balls

Dim ball(20)
Dim yspeed#(20)

For i=1 To 20
	ball(i)=CreateSphere()
	PositionEntity ball(i),Rand(-5,5),10+Rand(-5,5),10+Rand(-25,25)
	EntityType ball(i),2
Next

Collisions 2,1,2,3


; bounce the balls until the escape key is hit

While Not KeyHit(1)
	CameraZoom camera,1+MouseY()/200
	For i=1 To 20
		If EntityCollided(ball(i),1) 
			yspeed(i)=Abs(yspeed(i))
		EndIf
		yspeed(i)=yspeed(i)-.01
		MoveEntity ball(i),0,yspeed(i),0		
	Next
	UpdateWorld		
	RenderWorld
	Flip
Wend

End
; blockbuilder example

Graphics3D 640,480

light=CreateLight()

camera=CreateCamera()
PositionEntity camera,0,-10,-10
PointEntity camera,light

Collisions 1,1,1,1

For x=1 To 8
	For y=1 To 8
		cube=CreateCube()
		EntityColor cube,x*20,y*20,255
		PositionEntity cube,(x-4.5)*2,(y-4.5)*2,0
		EntityPickMode cube,3
	Next
Next

; click on blocks to grow them higher

While Not KeyHit(1)
	If MouseHit(1)
		CameraPick camera,MouseX(),MouseY()
		cube=PickedEntity()
		If cube
			Local name$=EntityName(cube)
			NameEntity cube,name+"*"
			ScaleEntity cube,1,1,Len(name)+2
		EndIf
	EndIf
	UpdateWorld
	RenderWorld
	Flip
Wend
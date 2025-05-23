; viewcube 

Function maketexture()
	t=CreateTexture(8,8,1)
	b=TextureBuffer(t)
	For x=0 To 31
		For y=0 To 31
			c=0
			If (x*y)And 1 c=-1
			WritePixel x,y,c,b
		Next
	Next
	Return t
End Function
			
Graphics3D 1280,1024;640,480

camera=CreateCamera()
MoveEntity camera,0,0,-1

CreateLight

; blue ground plane

plane=CreatePlane()
;PositionEntity plane,0,-0.99,0
EntityColor plane,100,120,240

; reference cube

cube=CreateCube()
FlipMesh cube
ScaleMesh cube,640.0/480,1,2
EntityTexture cube,maketexture()

pivot=CreatePivot()

While Not KeyHit(1)

	x#=(MouseX()-320)/320.0
	y#=(240-MouseY())/240.0
	PositionEntity pivot,x,y,1
;	PointEntity camera,pivot

	RenderWorld
	Flip
Wend

End

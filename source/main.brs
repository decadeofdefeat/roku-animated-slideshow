Function Main() As Void

   ns = NewSlideShow()
   ns.Initialize()
   ns.Show()

   ns.Clear()
   ns = Invalid

End Function

' Create a slide show object
Function NewSlideShow() As Object

   ns = CreateObject("roAssociativeArray")

   ' config settings
   ns.FETCH_URL = "http://yourwebsite.com/json_example.php"
   ns.IMAGE_WIDTH = 1280
   ns.IMAGE_HEIGHT = 720
   ns.SLIDE_DISPLAY_TIME = 15000
   ns.ANIMATION_TIME = 160

   ns.Screen     = Invalid
   ns.Device     = Invalid
   ns.Timer      = Invalid
   ns.Port       = Invalid
   ns.Compositor = Invalid

   ns.JSON_ARRAY = Invalid

   ns.TEMP_IMG_ARRAY = Invalid

   ns.SLIDE_TOTAL = Invalid



   ns.SlideBitmap = Invalid
   ns.SlideRegion = Invalid
   ns.SlideSprite = Invalid

   ns.SlideBitmap2 = Invalid
   ns.SlideRegion2 = Invalid
   ns.SlideSprite2 = Invalid

   ns.SLIDE_INDEX = 0

   ns.SWAP_BOOLEAN = false

   ' Sprite Z order or layers
   ns.SLIDE_1_Z = 0
   ns.SLIDE_2_Z = 1


   ns.Transparent = &h00000000
   ns.ScrBkgClr   = &hE0DFDFFF

   ns.Initialize = init
   ns.Show       = show_screen
   ns.EventLoop  = event_loop

   ns.Draw    = slideshow_draw
   ns.DrawAll = slideshow_drawall
   ns.MoveHandler = move_handler
   ns.LoadImage = load_image_into_sprite

   return ns
End Function


Function init() As Void

   ' Create all objects to be used
   m.Device     = CreateObject("roDeviceInfo")
   m.Timer      = CreateObject("roTimeSpan")
   m.Port       = CreateObject("roMessagePort")
   m.Compositor = CreateObject("roCompositor")


   ' Calculate size and position of the slideshow
   l_device_rect = m.Device.GetDisplaySize()
   l_x      = int(l_device_rect.w / 2 - m.IMAGE_WIDTH / 2)
   l_y      = int(l_device_rect.h / 2 - m.IMAGE_HEIGHT / 2)


   m.JSON_ARRAY = fetch_JSON( m.FETCH_URL )

   'print "json array counts is " +  m.JSON_ARRAY.photos.count()

   m.TEMP_IMG_ARRAY = CreateObject("roArray", 8, true)

   slideCount = 0
   for each img in m.JSON_ARRAY.photos


       slideCountString = (slideCount).tostr()
       slideTempFile = "tmp:/image"+ slideCountString +".jpg"

       xfer = createObject("roUrlTransfer")
       xfer.setUrl(img.url)
       ? "get to file", xfer.getToFile( slideTempFile )

       m.TEMP_IMG_ARRAY.push( slideTempFile )

       'print "image in temp array is " + m.TEMP_IMG_ARRAY[slideCount]

        if(slideCount = 0) then
            m.LoadImage( slideTempFile, 1, false )
        else if(slideCount = 1) then
            m.LoadImage( slideTempFile, 2, false )
        end if
        slideCount = slideCount + 1


   end for

   m.SLIDE_INDEX  = 1
   m.SLIDE_TOTAL = slideCount

   return
End Function


Function show_screen() As Void

   m.Screen = CreateObject("roScreen", True)
   m.Screen.SetMessagePort(m.Port)
  'm.Screen.SetAlphaEnable(True)
   m.Compositor.SetDrawTo(m.Screen, m.ScrBkgClr)

   m.DrawAll()
   m.EventLoop()

End Function

Function slideshow_drawall() As Void
   m.Compositor.DrawAll()
   m.Screen.SwapBuffers()
End Function

Function slideshow_draw() As Void
   m.Compositor.Draw()
   m.Screen.SwapBuffers()
End Function

Function event_loop() As Void

   l_msg     = ""
   l_running = true

   while(l_running)
      l_msg = wait(m.SLIDE_DISPLAY_TIME, m.port)
      if type(l_msg) = "roUniversalControlEvent"
        ' to do make control with left and right arrows
      else
        m.MoveHandler()
      end if
   end while


End Function



Function load_image_into_sprite( url as String, index as Integer, refresh as Boolean ) As Void

    'print "file loading now is " + url

   if (index = 1) then

        if( refresh = true ) then
           m.SlideSprite.Remove()
        end if

        m.SlideBitmap = Invalid
        m.SlideRegion = Invalid
        m.SlideSprite = Invalid
        m.SlideBitmap = CreateObject("roBitmap", url)

        ' what if image needs to be scaled? do later
        'scaledBitmap = createobject("roBitmap",{width:m.IMAGE_WIDTH,height:m.IMAGE_HEIGHT,alphaenable:false})
        'scaledBitmap.DrawScaledObject(0,0,0.67,0.67,m.SlideBitmap)

        m.SlideRegion = CreateObject("roRegion", m.SlideBitmap, 0, 0 , m.IMAGE_WIDTH, m.IMAGE_HEIGHT)
        m.SlideSprite = m.Compositor.NewSprite(0, 0, m.SlideRegion,  m.SLIDE_1_Z)

   else

        if( refresh = true ) then
           m.SlideSprite2.Remove()
        end if

        m.SlideBitmap2 = Invalid
        m.SlideRegion2 = Invalid
        m.SlideSprite2 = Invalid
        m.SlideBitmap2 = CreateObject("roBitmap", url)

        ' what if image needs to be scaled? do later
        'scaledBitmap = createobject("roBitmap",{width:m.IMAGE_WIDTH,height:m.IMAGE_HEIGHT,alphaenable:false})
        'scaledBitmap.DrawScaledObject(0,0,0.67,0.67,m.SlideBitmap2)

        m.SlideRegion2 = CreateObject("roRegion", m.SlideBitmap2, 0, 0 , m.IMAGE_WIDTH, m.IMAGE_HEIGHT)
        m.SlideSprite2 = m.Compositor.NewSprite( m.IMAGE_WIDTH, 0, m.SlideRegion2,  m.SLIDE_2_Z)
   end if


End Function



Function move_handler() As Void

    time   = 0
    duration      = m.ANIMATION_TIME

    for i = 0 to duration

        firstX = inoutquart( time + i ,0,-1280 ,duration)
        secondX = inoutquart( time + i, 1280,-1280,duration)

        if( m.SWAP_BOOLEAN = false ) then
            m.SlideSprite.MoveTo(firstX, 0)
            m.SlideSprite2.MoveTo(secondX, 0)
        else
            m.SlideSprite2.MoveTo(firstX, 0)
            m.SlideSprite.MoveTo(secondX, 0)
        end if

        m.DrawAll()

    end for


    m.SLIDE_INDEX = m.SLIDE_INDEX + 1

    if( m.SLIDE_INDEX = m.SLIDE_TOTAL ) then
        m.SLIDE_INDEX = 0
    end if

    if( m.SWAP_BOOLEAN = false ) then
        m.LoadImage( m.TEMP_IMG_ARRAY[m.SLIDE_INDEX], 1, true )
        m.SWAP_BOOLEAN = true
    else
        m.LoadImage( m.TEMP_IMG_ARRAY[m.SLIDE_INDEX], 2, true )
        m.SWAP_BOOLEAN = false
    end if

End Function




Function inoutquart(t as float,b as float,c as float,d as float) as float
                't=time, b=startvalue, c=change in value, d=duration
                d=d/2
                t=t/d
                if (t < 1) then return c/2*t*t*t*t + b
                     t=t-2
                return -c/2 * (t*t*t*t - 2) + b
end Function




Function fetch_JSON(url as string) as Object

    xfer = createobject("roURLTransfer")
    xfer.seturl(url)
    data = xfer.gettostring()
    json = ParseJSON(data)

    return json
End Function
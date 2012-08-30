uses windows;
{&H+}

const WinampClassName = 'winamp v1.x';
var wClass:TWndClass;
hFont,hInst,Handle,hPrev,hPlay,hPause,hStop,hNext,
hExit,hLabel,hvolup,hvoldown,hwnd_winamp,habout:HWND;
Msg:TMSG;
dPrev,dPlay,dPause,dStop,dvolup,dvoldown,dNext,dExit,dabout:Pointer;

procedure ShutDown;
begin
 DeleteObject(hFont);
  UnRegisterClass('WinAmpRemote_by_DAS_Class',hInst);
   Halt;
end;

procedure about;
begin
 MessageBoxEx(handle,'Cool WinAmp remote'+#10#13+
                     'by Dmitriy Stepanov (2:5070/251@fido)'+#10#13+
                     'written on Virtual Pascal (vpascal.com)'+#10#13+
                     'uses only WinApi functions','WinAmp Remote',0,0);
end;

procedure command(command:word); export;
begin
 hwnd_winamp := FindWindow(WinampClassName,nil);
  SendMessage(hwnd_winamp,WM_COMMAND,command,0);
end;

function track_name:string; export;
var s:string[255];
const
 name='Winamp';
 paused='[Paused]';
 stopped='[Stopped]';
begin
  hwnd_winamp:=FindWindow(WinampClassName,nil);
  if hwnd_winamp=0 then s:='Тишина' else begin
  S[0]:=chr(GetWindowTextLength(hwnd_winamp));
  GetWindowText(hwnd_winamp,@s[1],GetWindowTextLength(hwnd_winamp)+1);
  if s[1]='' then s:='Тишина' else
  if pos(name,s)=1 then s:='Тишина' else
  if pos(stopped,s)>1 then s:=stopped else
  if pos(paused,s)>1 then s:=paused else
   begin
    delete(s,Length(s)-(Length(name)+2),Length(name)+4);
    delete(s,1,pos('.',s));
   end; end;
  result:=s;
end;

procedure timerproc;
var p:pchar;
begin
 setwindowtext(hLabel,pchar(track_name));
end;

function WindowProc(hWnd,Msg,wParam,lParam:dword):Longint; stdcall;
begin
  Result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  case Msg of
   WM_COMMAND :      if lParam=hPrev    then command(40044)
                else if lParam=hPlay    then command(40045)
                else if lParam=hPause   then command(40046)
                else if lParam=hStop    then command(40047)
                else if lParam=hNext    then command(40048)
                else if lParam=hVolup   then command(40058)
                else if lParam=hVoldown then command(40059)
                else if lParam=hAbout   then about
                else if lParam=hExit    then shutdown;
   WM_DESTROY : ShutDown;
   WM_TIMER   : timerproc;
   WM_PAINT   : begin
                 SetForegroundWindow(Handle);
                 SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE+SWP_NOSIZE);
                end;
  end;
end;

exports
  command index 1 name 'command_to_amp',
  about index 2 name 'about_amprmt',
  track_name index 3 name 'get_track_name';


begin
 hInst:=GetModuleHandle(nil);
  with wClass do begin
    Style:=         CS_PARENTDC;
    hIcon:=         LoadIcon(hInst,'MAINICON');
    lpfnWndProc:=   @WindowProc;
    hInstance:=     hInst;
    hbrBackground:= COLOR_BTNFACE+1;
    lpszClassName:= 'AmpRmt';
    hCursor:=       LoadCursor(0,IDC_ARROW);
   end;
    RegisterClass(wClass);

    Handle:=CreateWindowEx(WS_EX_TOOLWINDOW,'AmpRmt','WinAmp Remote', WS_POPUP or WS_VISIBLE,0,0,261,25,0,0,hInst,nil);

    hPrev   :=CreateWindow('Button','Prev'     ,WS_VISIBLE or WS_CHILD,0  ,0 ,30, 15, Handle,0,hInst,nil);
    hPlay   :=CreateWindow('Button','Play'     ,WS_VISIBLE or WS_CHILD,29 ,0 ,30, 15, Handle,0,hInst,nil);
    hPause  :=CreateWindow('Button','Pause'    ,WS_VISIBLE or WS_CHILD,58 ,0 ,30, 15, Handle,0,hInst,nil);
    hStop   :=CreateWindow('Button','Stop'     ,WS_VISIBLE or WS_CHILD,87 ,0 ,30, 15, Handle,0,hInst,nil);
    hNext   :=CreateWindow('Button','Next'     ,WS_VISIBLE or WS_CHILD,116,0 ,30, 15, Handle,0,hInst,nil);
    hvolup  :=CreateWindow('Button','Vol +'    ,WS_VISIBLE or WS_CHILD,145,0 ,30, 15, Handle,0,hInst,nil);
    hvoldown:=CreateWindow('Button','Vol -'    ,WS_VISIBLE or WS_CHILD,174,0 ,30, 15, Handle,0,hInst,nil);
    habout  :=CreateWindow('Button','About'    ,WS_VISIBLE or WS_CHILD,203,0 ,30, 15, Handle,0,hInst,nil);
    hExit   :=CreateWindow('Button','Exit'     ,WS_VISIBLE or WS_CHILD,232,0 ,30, 15, Handle,0,hInst,nil);
    hLabel  :=CreateWindow('Static',pchar(track_name) ,WS_VISIBLE or WS_CHILD,0  ,14,261,15, Handle,0,hInst,nil);

    hFont:=CreateFont(-9,0,0,0,0,0,0,0,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,DEFAULT_PITCH or FF_DONTCARE,'Arial');

    SendMessage(hprev    ,WM_SETFONT,hFont,0);
    SendMessage(hplay    ,WM_SETFONT,hFont,0);
    SendMessage(hpause   ,WM_SETFONT,hFont,0);
    SendMessage(hstop    ,WM_SETFONT,hFont,0);
    SendMessage(hvolup   ,WM_SETFONT,hFont,0);
    SendMessage(hvoldown ,WM_SETFONT,hFont,0);
    SendMessage(hnext    ,WM_SETFONT,hFont,0);
    SendMessage(hexit    ,WM_SETFONT,hFont,0);
    SendMessage(habout   ,WM_SETFONT,hFont,0);
    SendMessage(hLabel   ,WM_SETFONT,hFont,0);

    dPrev    :=Pointer(GetWindowLong(hPrev    ,GWL_WNDPROC));
    dPlay    :=Pointer(GetWindowLong(hPlay    ,GWL_WNDPROC));
    dPause   :=Pointer(GetWindowLong(hPause   ,GWL_WNDPROC));
    dStop    :=Pointer(GetWindowLong(hStop    ,GWL_WNDPROC));
    dvolup   :=Pointer(GetWindowLong(hVolup   ,GWL_WNDPROC));
    dvoldown :=Pointer(GetWindowLong(hVoldown ,GWL_WNDPROC));
    dNext    :=Pointer(GetWindowLong(hNext    ,GWL_WNDPROC));
    dAbout   :=Pointer(GetWindowLong(hAbout   ,GWL_WNDPROC));
    dExit    :=Pointer(GetWindowLong(hExit    ,GWL_WNDPROC));

 while(GetMessage(Msg,Handle,0,0))do
  begin
   TranslateMessage(Msg);
   DispatchMessage(Msg);
  end;
end.

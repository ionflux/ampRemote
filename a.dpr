program a;
uses
 Windows, Messages;

const
 mainDialog  = 101;
 mainAbout   = 103;
             
 btnPrev     = 1000;
 btnPlay     = 1001;
 btnPause    = 1002;
 btnStop     = 1003;
 btnNext     = 1004;
 btnVolUp    = 1005;
 btnVolDown  = 1006;
 btnAbout    = 1007;
 btnExit     = 1008;

 chkLoadAmp  = 1015;
 editText    = 1016;

 lblsongText = 1009;

var onTop: boolean;

function GetAmpTitle: pChar;
var
  hWinamp: HWND;
  szTitle: string[255];
  Fnd: Integer;
  status: string;
begin
 hWinamp := FindWindow(pChar('Winamp v1.x'),nil );
 if hWinamp > 0 then
  begin
   szTitle[0] := chr(GetWindowTextLength(hWinamp));
   GetWindowText(hWinamp, @szTitle, sizeof(szTitle));
   if length(szTitle) > 6 then
     begin
      Fnd := Pos('.', szTitle);
      if Fnd <> 0 then Delete(szTitle, 1, Fnd+1);

      if Pos('[Paused]', szTitle) > 0 then status := ' [paused]' else
      if Pos('[Stopped]', szTitle) > 0 then status := ' [stoped]';

      Fnd := Pos('- Wina', szTitle);
      if Fnd <> 0 then Delete(szTitle, Fnd, Length(szTitle));

      if length(szTitle) = 3 then result:= '' else result := pChar(szTitle[1]);

     end else result := '';
 end else result := '';
end;

procedure command(command:word);
var hwnd_winamp: integer;
begin
 hwnd_winamp := FindWindow('winamp v1.x',nil);
  SendMessage(hwnd_winamp,WM_COMMAND,command,0);
end;

function aboutDialogFunc(Dialog: HWnd; Msg: UINT; wParam: WParam; lParam: LParam): Bool; stdcall;
begin
  result:= True;

  onTop := false;

  case Msg of
    wm_InitDialog: Exit;
    wm_Command:
    case loword(WParam) of
     1017: begin
            EndDialog(Dialog, 2);
            onTop := true;
           end;
    end;
  end;
  result:= False;
end;

function mainDialogFunc(Dialog: HWnd; Msg: UINT; wParam: WParam; lParam: LParam): Bool; stdcall;
begin
  result:= True;

  case Msg of
    wm_InitDialog: Exit;  
    wm_Paint : if onTop then 
               begin
                SetForegroundWindow(Dialog);
                SetWindowPos(Dialog,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE+SWP_NOSIZE);
                Setfocus(0);
                SetDlgItemText(Dialog,lblsongText,pChar(GetAmpTitle));
               end;
    wm_Close: EndDialog(Dialog, 2);
    wm_Command:
    case loword(WParam) of
     btnPrev:    command(40044);
     btnPlay:    command(40045);
     btnPause:   command(40046);
     btnStop:    command(40047);
     btnNext:    command(40048);
     btnVolUp:   command(40058);
     btnVolDown: command(40059);
     btnAbout:   DialogBoxParam(hInstance, pChar(mainAbout), Dialog, @mainDialogFunc,0);
     btnExit:    EndDialog(Dialog, 2);
    end;
  end;
  result:= False;
end;

{$r main.res}

begin
 onTop := true;
 DialogBoxParam(hInstance, PChar(mainDialog), 0, @mainDialogFunc, 0);
end.
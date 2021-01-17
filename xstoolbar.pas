unit XSToolBar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, FileUtil, Forms, Math,
  LCLType, LCLintf, ImgList, Graphics, GraphType, Types, Dialogs, LResources;

type
  { TXSToolButton }
  TXSToolBar = class;

  TXSToolButton = class(TObject)
  public
    Tag         : integer;
    ImageIndex  : integer;
    Parent      : TXSToolBar;
    constructor Create(TheOwner: TComponent);
  private
    X,Y         : integer;
    Width       : integer;
    FOnClick    : TNotifyEvent;
    FMode       : boolean;
    fEnabled    : boolean;
    procedure   SetEnabled(const AValue: boolean);
  published
    property    OnClick: TNotifyEvent read FOnClick write FOnClick;
    property    Mode: boolean read FMode write FMode;
    property    Enabled: boolean read fEnabled write SetEnabled;
  end;

  { TXSToolBar }

  TXSToolBar = class(TCustomControl)
  private
    FImages     : TCustomImageList;
    FList       : TStringList;
    fCount      : integer;
    foffset     : integer;
    fdown       : boolean;
    tmpoffs     : integer;
    procedure   GetButtonAtMousePos(X,Y: Integer);
  protected
    procedure   Paint; override;
    procedure   MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    procedure   MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    procedure   MouseMove(Shift: TShiftState; X,Y: Integer); override;
    procedure   OnShowHintSelf(Sender: TObject; HintInfo: PHintInfo);
    procedure   MouseEnter; override;
    procedure   MouseLeave; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   AddButton(HintName: string; tb: TXSToolButton);
    procedure   AddSeparator;
  published
    property    Images: TCustomImageList read FImages write FImages;
    property    Count : integer read fCount write fCount;
    property    Align;
    property    Anchors;
    property    BorderSpacing;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I xstoolbar_icon.lrs}
  RegisterComponents('XSComponent',[TXSToolBar]);
end;

{TXSToolButton}

constructor TXSToolButton.Create(TheOwner: TComponent);
begin
  inherited Create;
  Parent := TXSToolBar(TheOwner);
  ImageIndex := -1;
  X   := 0;
  Y   := 0;
  tag := 0;
  width := 36;
  Enabled := true;
  FMode := false;
end;

procedure TXSToolButton.SetEnabled(const AValue: boolean);
begin
  if AValue<>fEnabled then begin
    fEnabled := AValue;
    if Parent <> nil then
      InvalidateRect(Parent.handle,NIL,false);
  end;
end;

constructor TXSToolBar.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Height := 36;
  Align  := alTop;
//  Images := TCustomImageList.Create(Self);
//  Images :=nil;
  FList  := TStringList.Create;
  fCount := -1;
  foffset:= -1;
  DoubleBuffered:=true;
  fdown := false;
  Color := clMenuBar;
  ShowHint := true;
  OnShowHint := @OnShowHintSelf;
end;

destructor TXSToolBar.Destroy;
var
  i: integer;
begin
  for i:=0 to FList.Count-1 do FList.Objects[i].Free;
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TXSToolBar.AddButton(HintName: string; tb: TXSToolButton);
begin
  tb.X := 4;
  if FList.Count>0 then tb.X := TXSToolButton(FList.Objects[FList.Count-1]).X+TXSToolButton(FList.Objects[FList.Count-1]).width+2;
  tb.Y := 2;
  tb.Mode := false;
  FList.AddObject(HintName,tb);
end;

procedure TXSToolBar.AddSeparator;
var
  tb: TXSToolButton;
begin

  tb := TXSToolButton.Create(Self);
  tb.Width:=3;
  tb.X := 2;
  if FList.Count>0 then tb.X := TXSToolButton(FList.Objects[FList.Count-1]).X+TXSToolButton(FList.Objects[FList.Count-1]).width+2;
  tb.Y := 4;
  tb.Mode := true;
  FList.AddObject('',tb);
end;

procedure TXSToolBar.GetButtonAtMousePos(X,Y: Integer);
var
  i: integer;
  flag: boolean;
begin
  i:=0;
  flag := false;
  while (i<FList.Count) and not flag do begin
    if (X>=TXSToolButton(FList.Objects[i]).X) and (X<=TXSToolButton(FList.Objects[i]).X+TXSToolButton(FList.Objects[i]).width)
    and (Y>=TXSToolButton(FList.Objects[i]).Y) and (Y<=TXSToolButton(FList.Objects[i]).Y+height-TXSToolButton(FList.Objects[i]).Y)
    and not TXSToolButton(FList.Objects[i]).mode then begin
      foffset := i;
      flag := true;
    end;
    inc(i);
  end;
end;

procedure TXSToolBar.OnShowHintSelf(Sender: TObject; HintInfo: PHintInfo);
var
  Pos : TPoint;
begin
  if foffset=-1 then exit;
  with HintInfo^ do begin
    Pos.X := TXSToolButton(FList.Objects[foffset]).X + TXSToolButton(FList.Objects[foffset]).width;
    Pos.Y := -TXSToolButton(FList.Objects[foffset]).width;
    HintPos := ClientToScreen(Pos);
    HintStr := FList[foffset];
  end;
end;

procedure TXSToolBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  GetButtonAtMousePos(X,Y);
  tmpoffs:=foffset;
  fdown := Button=mbLeft;
  InvalidateRect(handle,NIL,false);
  Invalidate;
end;

procedure TXSToolBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  foffset := -1;
  if fdown then exit;
  GetButtonAtMousePos(X,Y);
  if foffset>-1 then begin
    Application.CancelHint;
    if TXSToolButton(FList.Objects[foffset]).Enabled then
      Application.ActivateHint(ClientToScreen(Point(0,0)));
  end;
  InvalidateRect(handle,NIL,false);
  Invalidate;
end;

procedure TXSToolBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  GetButtonAtMousePos(X,Y);
  if fdown and (foffset=tmpoffs) and (foffset>-1) then begin
    fdown := false;
    InvalidateRect(handle,NIL,false);
    if TXSToolButton(FList.Objects[foffset]).Enabled and Assigned(TXSToolButton(FList.Objects[foffset]).FOnClick) then TXSToolButton(FList.Objects[foffset]).FOnClick(TXSToolButton(FList.Objects[foffset]));
  end;
  fdown := false;
  InvalidateRect(handle,NIL,false);
  Invalidate;
end;

procedure TXSToolBar.MouseEnter;
begin
  inherited MouseEnter;
  foffset := -1;
  InvalidateRect(handle,NIL,false);
  Invalidate;
end;

procedure TXSToolBar.MouseLeave;
begin
  inherited MouseLeave;
  foffset := -1;
  InvalidateRect(handle,NIL,false);
  Invalidate;
end;

procedure TXSToolBar.Paint;
var
  i,j: integer;
begin
  for i:=0 to FList.Count-1 do begin
    if TXSToolButton(FList.Objects[i]).Mode then
    begin
      Canvas.Pen.Color  := clMenuBar;
      Canvas.Brush.Color:= clInactiveCaption;;
    end
    else
    if TXSToolButton(FList.Objects[i]).Enabled then
    begin
      Canvas.Pen.Color  := clMenuBar;//$E0E0E0;
      Canvas.Brush.Color:= clMenuBar;//$E0E0E0;
    end
    else
    begin
      Canvas.Pen.Color  := clMenuBar;//clWhite; //enbled
      Canvas.Brush.Color:= clMenuBar;  //toshe
    end;
    j:=0;
    if TXSToolButton(FList.Objects[i]).Enabled and (foffset = i) then begin
      if fdown then begin
        Canvas.Pen.Color  := clInactiveCaption;
        Canvas.Brush.Color:= clHighlight;//$D8D8D8;
        j:=1;
      end else begin
        Canvas.Pen.Color  := clInactiveCaption;//$D0D0D0;
        Canvas.Brush.Color:= clBtnHighlight;
      end;
    end;
    Canvas.RoundRect(TXSToolButton(FList.Objects[i]).X,TXSToolButton(FList.Objects[i]).Y,TXSToolButton(FList.Objects[i]).X+TXSToolButton(FList.Objects[i]).width,height-TXSToolButton(FList.Objects[i]).Y,4,4);
    if (Images<>NIL) and (TXSToolButton(FList.Objects[i]).ImageIndex>-1)  then
    begin
     if TXSToolButton(FList.Objects[i]).enabled then
     Images.Draw(Canvas,TXSToolButton(FList.Objects[i]).X+(TXSToolButton(FList.Objects[i]).width-FImages.Width) div 2,(height - FImages.height) div 2 + j,TXSToolButton(FList.Objects[i]).ImageIndex,TXSToolButton(FList.Objects[i]).enabled)
     else
     Images.Draw(Canvas,TXSToolButton(FList.Objects[i]).X+(TXSToolButton(FList.Objects[i]).width-FImages.Width) div 2,(height - FImages.height) div 2 + j,TXSToolButton(FList.Objects[i]).ImageIndex,gdeHighlighted);
   end;
  end;
end;


end.

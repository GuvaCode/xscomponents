unit XSPanel;

{$mode objfpc}{$H+}
 //
interface

uses
  Classes, SysUtils, Controls, ExtCtrls, FileUtil, Forms, Math,
  LCLType, LCLintf, ImgList, Graphics, GraphType, Types, Dialogs, LResources;

type
  { TXSPanel }
  TXSPanel = class(TCustomControl)
   private
    FActiveBorderColor: TColor;
    fclose      : boolean;
    FCloseColor: TColor;
    FCloseDownColor: TColor;
    fdown       : boolean;
    closerect   : TRect;
    FImageIndex: integer;
    FImages     : TCustomImageList;
    FNoActiveBorderColor: TColor;
    FOnCloseClick: TNotifyEvent;
    hdrheight   : integer;
    procedure SetActiveBorderColor(AValue: TColor);
    procedure SetCloseColor(AValue: TColor);
    procedure SetCloseDownColor(AValue: TColor);
    procedure SetImageIndex(AValue: integer);
    procedure SetImages(const AValue: TCustomImageList);
    procedure SetNoActiveBorderColor(AValue: TColor);
  protected
    procedure   Paint; override;
    procedure   Resize; override;
    procedure   MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    procedure   MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    procedure   MouseMove(Shift: TShiftState; X,Y: Integer); override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor  Destroy; override;
  published
    property    Images: TCustomImageList read FImages write SetImages;
    property    ImageIndex: integer read FImageIndex write SetImageIndex default -1;
    property    OnCloseClick: TNotifyEvent read FOnCloseClick write FOnCloseClick;
    property    ActiveBorderColor:TColor read FActiveBorderColor write SetActiveBorderColor;
    property    NoActiveBorderColor:TColor read FNoActiveBorderColor write SetNoActiveBorderColor;
    property    CloseDownColor:TColor read FCloseDownColor write SetCloseDownColor;
    property    CloseColor:TColor read FCloseColor write SetCloseColor;
    property    Align;
    property    Anchors;
    property    AutoSize;
    property    Color;
    property    Caption;
    property    Font;
    property    Visible;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I xspanel_icon.lrs}
  RegisterComponents('XSComponent',[TXSPanel]);
end;

{ TXSPanel }

constructor TXSPanel.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FActiveBorderColor         :=$E0E0E0;
  FNoActiveBorderColor       :=$E5E5E5;
  FCloseDownColor            :=clRed;
  FCloseColor                :=clGray;
  FimageIndex                :=-1;
  color                      :=clWhite;
  hdrheight  := 22;
  width      := 100;
  height     := 100;
  Font.Color:=clGray;
  ChildSizing.TopBottomSpacing:=hdrheight+4;
  ChildSizing.LeftRightSpacing:=2;
  ControlStyle := ControlStyle + [csAcceptsControls];
end;

destructor TXSPanel.Destroy;
begin

  inherited Destroy;
end;

procedure TXSPanel.SetImages(const AValue: TCustomImageList);
begin
  if FImages<>AValue then
    FImages:=AValue;
end;

procedure TXSPanel.SetNoActiveBorderColor(AValue: TColor);
begin
  if FNoActiveBorderColor=AValue then Exit;
  FNoActiveBorderColor:=AValue;
end;

procedure TXSPanel.SetActiveBorderColor(AValue: TColor);
begin
  if FActiveBorderColor=AValue then Exit;
  FActiveBorderColor:=AValue;
end;

procedure TXSPanel.SetCloseColor(AValue: TColor);
begin
  if FCloseColor=AValue then Exit;
  FCloseColor:=AValue;
end;

procedure TXSPanel.SetCloseDownColor(AValue: TColor);
begin
  if FCloseDownColor=AValue then Exit;
  FCloseDownColor:=AValue;
end;

procedure TXSPanel.SetImageIndex(AValue: integer);
begin
  if FImageIndex=AValue then Exit;
  FImageIndex:= AValue;
  Invalidate;
end;

procedure TXSPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
var
  p: TControl;
begin
  inherited MouseDown(Button, Shift, X, Y);
  fdown := true;
  SetFocus;
  p := Parent;
  while p.Parent<>NIL do p := p.Parent;
  p.Invalidate;
end;

procedure TXSPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if PtInRect(closerect,Point(X,Y)) then
  begin
  visible:=false;
  if Assigned(FOnCloseClick) then FOnCloseClick(Self);
  end;

  fdown := false;
  fclose := false;
  Invalidate;
end;

procedure TXSPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if fdown then exit;
  fclose := PtInRect(closerect,Point(X,Y));
  Invalidate;
end;

procedure TXSPanel.Resize;
begin
  Invalidate;
end;

procedure TXSPanel.Paint;
var
  i: integer;
begin
  inherited Paint;

  Canvas.Pen.Color:=FActiveBorderColor;
  if Focused then
    Canvas.Brush.Color:= FActiveBorderColor
  else
    Canvas.Brush.Color:= FNoActiveBorderColor;

  Canvas.Font.Color := Font.color;
  Canvas.RoundRect(2,2,width-2,hdrheight+2,5,5);

 i := 10;
 if assigned(FImages) and (ImageIndex>-1) then
 begin
    Images.Draw(Canvas,5,(hdrheight - FImages.Height) div 2 + 2,ImageIndex,Focused);
    inc(i,FImages.Width);
    Canvas.TextOut(i,(hdrheight - FImages.Height) div 2 + 2,Caption);
  end else
    Canvas.TextOut(i,4,Caption);

  closerect := Rect(width-2-5-10,(hdrheight - 10) div 2 + 2,width-2-5,(hdrheight - 10) div 2 + 12);

  if fclose then
    Canvas.Pen.Color  := FCloseDownColor
  else
    Canvas.Pen.Color  := FCloseColor;

  Canvas.Line(closerect.Left+1,closerect.Top+1,closerect.Right,closerect.Bottom);
  Canvas.Line(closerect.Left+1,closerect.Top+2,closerect.Right-1,closerect.Bottom);
  Canvas.Line(closerect.Left+2,closerect.Top+1,closerect.Right,closerect.Bottom-1);

  Canvas.Line(closerect.Left+1,closerect.Bottom-1,closerect.Right,closerect.Top);
  Canvas.Line(closerect.Left+1,closerect.Bottom-2,closerect.Right-1,closerect.Top);
  Canvas.Line(closerect.Left+2,closerect.Bottom-1,closerect.Right,closerect.Top+1);
end;

end.

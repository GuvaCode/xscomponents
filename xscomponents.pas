{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit xscomponents;

{$warn 5023 off : no warning about unused units}
interface

uses
  XSPanel, XSToolBar, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('XSPanel', @XSPanel.Register);
  RegisterUnit('XSToolBar', @XSToolBar.Register);
end;

initialization
  RegisterPackage('xscomponents', @Register);
end.

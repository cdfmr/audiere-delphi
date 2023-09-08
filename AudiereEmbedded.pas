unit AudiereEmbedded;

interface

procedure LoadEmbeddedAudiere;
procedure UnloadEmbeddedAudiere;

implementation

{$R Audiere.res}

uses
  Windows, Classes, SysUtils, Audiere;

var
  AudiereFile: string;

function GetTempFile: TFileName;
var
  TempPath: array[0..MAX_PATH] of Char;
  FileName: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, TempPath);
  GetTempFileName(TempPath, 'audiere', 0, FileName);
  Result := StrPas(FileName);
end;

procedure LoadEmbeddedAudiere;
var
  AudiereResource: TResourceStream;
begin
  if AudiereHandle <> 0 then Exit;

  AudiereFile := GetTempFile;
  AudiereResource := TResourceStream.Create(hInstance, 'AUDIERE', 'BIN');
  try
    AudiereResource.SaveToFile(AudiereFile);
  finally
    AudiereResource.Free;
  end;

  if not LoadAudiere(PChar(AudiereFile)) then
    UnloadEmbeddedAudiere;
end;

procedure UnloadEmbeddedAudiere;
begin
  UnloadAudiere;
  DeleteFile(AudiereFile);
  AudiereFile := '';
end;

initialization
  // LoadEmbeddedAudiere;

finalization
  UnloadEmbeddedAudiere;

end.

//=========================================================================
// Audiere Sound System
// Version 1.9.5
// (c) 2002 Chad Austin
//
// This API uses principles explained at
// http://aegisknight.org/cppinterface.html
//
// This code licensed under the terms of the LGPL.  See the Audiere
// license.txt.
//-------------------------------------------------------------------------
// Delphi Conversion By:
// Jarrod Davis
// Jarrod Davis Software
// http://www.jarroddavis.com   - Jarrod Davis Software
// http://www.gamevisionsdk.com - Game Application Framework for Delphi
// support@jarroddavis.com      - Support Email
// Update to 1.9.5 by cdfmr.
//-------------------------------------------------------------------------
// How to use:
//   * Include Audiere in your Uses statement
//   * Enable or Disable the DYNAMICS compiler define
//   * If Dynamic, be sure to call LoadAudiere before using any commands.
//     the DLL will be automaticlly unloaded at termination.
//   * If Static, then use as normal.
// History:
//   * Initial 1.9.2 release.
//   + Added dynamic loading. Use the DYNAMIC compiler define to control
//     this. When enabled you can then use ArdLoadLL/UnloadAudiere to
//     dynamiclly load/unload dll at runtime.
//   * Update to 1.9.5.
//=========================================================================

unit Audiere;

{$A+}
{$Z4}
{$DEFINE DYNAMIC}

interface

const
  AudiereLibrary = 'audiere.dll';

type
  { TTag}
  PTag = ^TTag;
  TTag = class(TObject)
  public
    Key: string;
    Value: string;
    Category: string;
  end;

  { TAdrRefCounted  }
  PAdrRefCounted = ^TAdrRefCounted;
  TAdrRefCounted = class
  public
    procedure Ref;   virtual; stdcall; abstract;
    procedure UnRef; virtual; stdcall; abstract;
  end;

  { TAdrSeekMode  }
  TAdrSeekMode = (
    adrSeekBegin,
    adrSeekCurrent,
    adrSeekEnd
  );

  PAudioDeviceDesc = ^TAudioDeviceDesc;
  TAudioDeviceDesc = record
    Name : string;        // Name of device, i.e. "directsound", "winmm", or "oss"
    Description : string; // Textual description of device.
  end;

  { TAdrFile }
  PAdrFile = ^TAdrFile;
  TAdrFile = class(TAdrRefCounted)
  public
    function Read(aBuffer: Pointer; aSize: Integer): Integer; virtual; stdcall; abstract;
    function Seek(aPosition: Integer; aSeekMode: TAdrSeekMode): Boolean; virtual; stdcall; abstract;
    function Tell: Integer; virtual; stdcall; abstract;
  end;

  { TAdrSampleFormat }
  TAdrSampleFormat = (
    adrSampleU8,
    adrSampleS16
  );

  { TAdrFileFormat }
  TAdrFileFormat = (
    adrFormatAuto,
    adrFormatWave,
    adrFormatOgg,
    AdrFormatFLAC,
    adrFormatMP3,
    adrFormatMOD,
    adrFormatAIFF,
    adrFormatSpeex
  );

  { TAdrSampleSource }
  PAdrSampleSource = ^TAdrSampleSource;
  TAdrSampleSource = class(TAdrRefCounted)
  public
    procedure GetFormat(var aChannelCount: Integer; var aSampleRate: Integer; var aSampleFormat: TAdrSampleFormat); virtual; stdcall; abstract;
    function  Read(aFrameCount: Integer; aBuffer: Pointer): Integer;  virtual; stdcall; abstract;
    procedure Reset; virtual; stdcall; abstract;
    function  IsSeekable: Boolean; virtual; stdcall; abstract;
    function  GetLength: Integer; virtual; stdcall; abstract;
    procedure SetPosition(Position: Integer); virtual; stdcall; abstract;
    function  GetPosition: Integer; virtual; stdcall; abstract;
    procedure SetRepeat(aRepeat: boolean); virtual; stdcall; abstract;
    function  GetRepeat: boolean; virtual; stdcall; abstract;
    function  GetTagCount: Integer; virtual; stdcall; abstract;
    function  GetTagKey(aIndex: integer): PChar; virtual; stdcall; abstract;
    function  GetTagValue(aIndex: integer): PChar; virtual; stdcall; abstract;
    function  GetTagType(aIndex: integer): PChar; virtual; stdcall; abstract;
  end;

  { TAdrLoopPointSource }
  PAdrLoopPointSource = ^TAdrLoopPointSource;
  TAdrLoopPointSource = class(TAdrRefCounted)
  public
    procedure AddLoopPoint(aLocation: integer; aTarget:integer; aLoopCount: integer); virtual; stdcall; abstract;
    procedure RemoveLoopPoint(aIndex: integer); virtual; stdcall; abstract;
    function  GetLoopPointCount: integer; virtual; stdcall; abstract;
    function  GetLoopPoint(aIndex: integer; var aLocation: integer; var aTarget: integer; aLoopCount: integer): Boolean; virtual; stdcall; abstract;
  end;

  { TAdrOutputStream }
  PAdrOutputStream = ^TAdrOutputStream;
  TAdrOutputStream = class(TAdrRefCounted)
  public
    procedure Play; virtual; stdcall; abstract;
    procedure Stop; virtual; stdcall; abstract;
    function  IsPlaying: Boolean; virtual; stdcall; abstract;
    procedure Reset; virtual; stdcall; abstract;
    procedure SetRepeat(aRepeat: Boolean); virtual; stdcall; abstract;
    function  GetRepeat: Boolean; virtual; stdcall; abstract;
    procedure SetVolume(aVolume: Single); virtual; stdcall; abstract;
    function  GetVolume: Single; virtual; stdcall; abstract;
    procedure SetPan(aPan: Single); virtual; stdcall; abstract;
    function  GetPan: Single; virtual; stdcall; abstract;
    procedure SetPitchShift(aShift: Single); virtual; stdcall; abstract;
    function  GetPitchShift: Single; virtual; stdcall; abstract;
    function  IsSeekable: Boolean; virtual; stdcall; abstract;
    function  GetLength: Integer; virtual; stdcall; abstract;
    procedure SetPosition(aPosition: Integer); virtual; stdcall; abstract;
    function  GetPosition: Integer; virtual; stdcall; abstract;
  end;

  { TAdrEventType }
  TAdrEventType = (
    adrEventStop
  );

  { TAdrEvent  }
  PAdrEvent = ^TAdrEvent;
  TAdrEvent = class(TAdrRefCounted)
  public
    function GetType: TAdrEventType;   virtual; stdcall; abstract;
  end;

  { TAdrReason }
  TAdrReason = (
    adrReasonStop,
    adrReasonStreamEnded
  );

  { TAdrStopEvent }
  PAdrStopEvent = ^TAdrStopEvent;
  TAdrStopEvent = class(TAdrEvent(*TAdrRefCounted*))
  public
    function  GetType: TAdrEventType; override; stdcall; // virtual; stdcall; abstract;
    function  GetOutputStream: TAdrOutputStream; virtual; stdcall; abstract;
    function  GetReason: TAdrReason; virtual; stdcall; abstract;
  end;

  { TAdrCallback }
  PAdrCallback = ^TAdrCallback;
  TAdrCallback = class(TAdrRefCounted)
  public
    function  GetType: TAdrEventType; virtual; stdcall; abstract;
    procedure Call(aEvent: TAdrEvent); virtual; stdcall; abstract;
  end;

  { TAdrStopCallback }
  PAdrStopCallback = ^TAdrStopCallback;
  TAdrStopCallback = class(TAdrCallback(*TAdrRefCounted*))
  public
    procedure Ref;   override; stdcall; // virtual; stdcall; abstract;
    procedure UnRef; override; stdcall; // virtual; stdcall; abstract;
    function  GetType: TAdrEventType; override; stdcall; // virtual; stdcall; abstract;
    procedure Call(aEvent: TAdrEvent); override; stdcall; // virtual; stdcall; abstract;
    procedure StreamStopped(aStopEvent: TAdrStopEvent); virtual; stdcall; abstract;
  end;

  { TAdrAudioDevice }
  PAdrAudioDevice = ^TAdrAudioDevice;
  TAdrAudioDevice = class(TAdrRefCounted)
  public
    procedure Update; virtual; stdcall; abstract;
    function  OpenStream(aSource: TAdrSampleSource): TAdrOutputStream; virtual; stdcall; abstract;
    function  OpenBuffer(aSamples: Pointer; aFrameCount, aChannelCount, aSampleRate: Integer; aSampelFormat: TAdrSampleFormat):  TAdrOutputStream; virtual; stdcall; abstract;
    function  GetName: PChar; virtual; stdcall; abstract;
    procedure RegisterCallback(aCallback: TAdrCallback); virtual; stdcall; abstract;
    procedure UnregisterCallback(aCallback: TAdrCallback); virtual; stdcall; abstract;
    procedure ClearCallbacks; virtual; stdcall; abstract;
  end;

  { TAdrSampleBuffer }
  PAdrSampleBuffer = ^TAdrSampleBuffer;
  TAdrSampleBuffer = class(TAdrRefCounted)
  public
    procedure GetFormat(var ChannelCount: Integer; var aSampleRate: Integer; var aSampleFormat: TAdrSampleFormat); virtual; stdcall; abstract;
    function  GetLength: Integer; virtual; stdcall; abstract;
    function  GetSamples: Pointer; virtual; stdcall; abstract;
    function  OpenStream: TAdrSampleSource; virtual; stdcall; abstract;
  end;

  { TAdrSoundEffectType }
  TAdrSoundEffectType = (
    adrEffectSingle,
    adrEffectMultiple
  );

  { TAdrSoundEffect }
  PAdrSoundEffect = ^TAdrSoundEffect;
  TAdrSoundEffect = class(TAdrRefCounted)
  public
    procedure Play; virtual; stdcall; abstract;
    procedure Stop; virtual; stdcall; abstract;
    procedure SetVolume(aVolume: Single); virtual; stdcall; abstract;
    function  GetVolume: Single; virtual; stdcall; abstract;
    procedure SetPan(aPan: Single); virtual; stdcall; abstract;
    function  GetPan: Single; virtual; stdcall; abstract;
    procedure SetPitchShift(aShift: Single); virtual; stdcall; abstract;
    function  GetPitchShift: Single; virtual; stdcall; abstract;
  end;

  { TAdrCDDevice }
  PAdrCDDevice = ^TAdrCDDevice;
  TAdrCDDevice = class(TAdrRefCounted)
  public
    function  GetName: PChar; virtual; stdcall; abstract;
    function  GetTrackCount: integer; virtual; stdcall; abstract;
    procedure Play(aTrack: integer); virtual; stdcall; abstract;
    procedure Stop; virtual; stdcall; abstract;
    procedure Pause; virtual; stdcall; abstract;
    procedure Resume; virtual; stdcall; abstract;
    function  IsPlaying: Boolean; virtual; stdcall; abstract;
    function  ContainsCD: Boolean; virtual; stdcall; abstract;
    function  IsDoorOpen: Boolean; virtual; stdcall; abstract;
    procedure OpenDoor; virtual; stdcall; abstract;
    procedure CloseDoor; virtual; stdcall; abstract;
  end;

  { TAdrMIDIStream }
  PAdrMIDIStream = ^TAdrMIDIStream;
  TAdrMIDIStream = class(TAdrRefCounted)
  public
    procedure Play; virtual; stdcall; abstract;
    procedure Stop; virtual; stdcall; abstract;
    procedure Pause; virtual; stdcall; abstract;
    function  IsPlaying: Boolean; virtual; stdcall; abstract;
    function  GetLength: integer; virtual; stdcall; abstract;
    function  GetPosition: integer; virtual; stdcall; abstract;
    procedure SetPosition(aPositions: integer); virtual; stdcall; abstract;
    function  GetRepeat: Boolean; virtual; stdcall; abstract;
    procedure SetRepeat(aRepeat: Boolean); virtual; stdcall; abstract;
  end;

  { TAdrMIDIDevice }
  PAdrMIDIDevice = ^TAdrMIDIDevice;
  TAdrMIDIDevice = class(TAdrRefCounted)
  public
    function  GetName: PChar; virtual; stdcall; abstract;
    function  OpenStream(aFileName: PChar): TAdrMIDIStream; virtual; stdcall; abstract;
  end;


{ --- Audiere Routines -------------------------------------------------- }

{$IFNDEF DYNAMIC}

function  AdrCreateLoopPointSource        (aSource: TAdrSampleSource)                                                                            : TAdrLoopPointSource; stdcall; external AudiereLibrary name '_AdrCreateLoopPointSource@4';
function  AdrCreateMemoryFile             (aBuffer: Pointer; BufferSize: Integer)                                                                : TAdrFile;            stdcall; external AudiereLibrary name '_AdrCreateMemoryFile@8';
function  AdrCreateMemoryFileInPlace      (aBuffer: Pointer; BufferSize: Integer)                                                                : TAdrFile;            stdcall; external AudiereLibrary name '_AdrCreateMemoryFileInPlace@8';
function  AdrCreatePinkNoise                                                                                                                     : TAdrSampleSource;    stdcall; external AudiereLibrary name '_AdrCreatePinkNoise@0';
function  AdrCreateSampleBuffer           (aSamples: Pointer; aFrameCount, aChannelCount, aSampleRate: Integer; aSampleFormat: TAdrSampleFormat) : TAdrSampleBuffer;    stdcall; external AudiereLibrary name '_AdrCreateSampleBuffer@20';
function  AdrCreateSampleBufferFromSource (aSource: TAdrSampleSource)                                                                            : TAdrSampleBuffer;    stdcall; external AudiereLibrary name '_AdrCreateSampleBufferFromSource@4';
function  AdrCreateSquareWave             (aFrequency: Double)                                                                                   : TAdrSampleSource;    stdcall; external AudiereLibrary name '_AdrCreateSquareWave@8';
function  AdrCreateTone                   (aFrequency: Double)                                                                                   : TAdrSampleSource;    stdcall; external AudiereLibrary name '_AdrCreateTone@8';
function  AdrCreateWhiteNoise                                                                                                                    : TAdrSampleSource;    stdcall; external AudiereLibrary name '_AdrCreateWhiteNoise@0';
function  AdrEnumerateCDDevices                                                                                                                  : PChar;               stdcall; external AudiereLibrary name '_AdrEnumerateCDDevices@0';
function  AdrGetSampleSize                (aFormat: TAdrSampleFormat)                                                                            : Integer;             stdcall; external AudiereLibrary name '_AdrGetSampleSize@4';
function  AdrGetSupportedAudioDevices                                                                                                            : PChar;               stdcall; external AudiereLibrary name '_AdrGetSupportedAudioDevices@0';
function  AdrGetSupportedFileFormats                                                                                                             : PChar;               stdcall; external AudiereLibrary name '_AdrGetSupportedFileFormats@0';
function  AdrGetVersion                                                                                                                          : PChar;               stdcall; external AudiereLibrary name '_AdrGetVersion@0';
function  AdrOpenCDDevice                 (aName: PChar)                                                                                         : TAdrCDDevice;        stdcall; external AudiereLibrary name '_AdrOpenCDDevice@4';
function  AdrOpenDevice                   (const aName: PChar; const aParams: PChar)                                                             : TAdrAudioDevice;     stdcall; external AudiereLibrary name '_AdrOpenDevice@8';
function  AdrOpenFile                     (aName: PChar; aWritable: LongBool)                                                                    : TAdrFile;            stdcall; external AudiereLibrary name '_AdrOpenFile@8';
function  AdrOpenFileW                    (aName: PWideChar; aWritable: LongBool)                                                                : TAdrFile;            stdcall; external AudiereLibrary name '_AdrOpenFileW@8';
function  AdrOpenMIDIDevice               (aName: PChar)                                                                                         : TAdrMIDIDevice;      stdcall; external AudiereLibrary name '_AdrOpenMIDIDevice@4';
function  AdrOpenSampleSource             (const aFilename: PChar; aFileFormat: TAdrFileFormat)                                                  : TAdrSampleSource;    stdcall; external AudiereLibrary name '_AdrOpenSampleSource@8';
function  AdrOpenSampleSourceFromFile     (aFile: TAdrFile; aFileFormat: TAdrFileFormat)                                                         : TAdrSampleSource;    stdcall; external AudiereLibrary name '_AdrOpenSampleSourceFromFile@8';
function  AdrOpenSampleSourceW            (const aFilename: PWideChar; aFileFormat: TAdrFileFormat)                                              : TAdrSampleSource;    stdcall; external AudiereLibrary name '_AdrOpenSampleSourceW@8';
function  AdrOpenSound                    (aDevice: TAdrAudioDevice; aSource: TAdrSampleSource; aStreaming: LongBool)                            : TAdrOutputStream;    stdcall; external AudiereLibrary name '_AdrOpenSound@12';
function  AdrOpenSoundEffect              (aDevice: TAdrAudioDevice; aSource: TAdrSampleSource; aType: TAdrSoundEffectType)                      : TAdrSoundEffect;     stdcall; external AudiereLibrary name '_AdrOpenSoundEffect@12';
function  AdrSimpleIsPlaying                                                                                                                     : LongBool;            stdcall; external AudiereLibrary name '_AdrSimpleIsPlaying@0';
procedure AdrSimplePlay                   (aBuffer: Pointer; aSize: Longint; aLoop: LongBool; aFormat: TAdrFileFormat = adrFormatAuto)           :                      stdcall; external AudiereLibrary name '_AdrSimplePlay@16';
procedure AdrSimplePlayFile               (aFilename: PChar; aLoop: LongBool)                                                                    :                      stdcall; external AudiereLibrary name '_AdrSimplePlayFile@8';
procedure AdrSimplePlayFileW              (aFilename: PWideChar; aLoop: LongBool)                                                                :                      stdcall; external AudiereLibrary name '_AdrSimplePlayFileW@8';
procedure AdrSimpleStop                                                                                                                          :                      stdcall; external AudiereLibrary name '_AdrSimpleStop@0';

{$ENDIF}


{$IFDEF DYNAMIC}

var
  AdrCreateLoopPointSource        : function  (aSource: TAdrSampleSource)                                                                            : TAdrLoopPointSource; stdcall = nil;
  AdrCreateMemoryFile             : function  (aBuffer: Pointer; BufferSize: Integer)                                                                : TAdrFile;            stdcall = nil;
  AdrCreateMemoryFileInPlace      : function  (aBuffer: Pointer; BufferSize: Integer)                                                                : TAdrFile;            stdcall = nil;
  AdrCreatePinkNoise              : function                                                                                                         : TAdrSampleSource;    stdcall = nil;
  AdrCreateSampleBuffer           : function  (aSamples: Pointer; aFrameCount, aChannelCount, aSampleRate: Integer; aSampleFormat: TAdrSampleFormat) : TAdrSampleBuffer;    stdcall = nil;
  AdrCreateSampleBufferFromSource : function  (aSource: TAdrSampleSource)                                                                            : TAdrSampleBuffer;    stdcall = nil;
  AdrCreateSquareWave             : function  (aFrequency: Double)                                                                                   : TAdrSampleSource;    stdcall = nil;
  AdrCreateTone                   : function  (aFrequency: Double)                                                                                   : TAdrSampleSource;    stdcall = nil;
  AdrCreateWhiteNoise             : function                                                                                                         : TAdrSampleSource;    stdcall = nil;
  AdrEnumerateCDDevices           : function                                                                                                         : PChar;               stdcall = nil;
  AdrGetSampleSize                : function  (aFormat: TAdrSampleFormat)                                                                            : Integer;             stdcall = nil;
  AdrGetSupportedAudioDevices     : function                                                                                                         : PChar;               stdcall = nil;
  AdrGetSupportedFileFormats      : function                                                                                                         : PChar;               stdcall = nil;
  AdrGetVersion                   : function                                                                                                         : PChar;               stdcall = nil;
  AdrOpenCDDevice                 : function  (aName: PChar)                                                                                         : TAdrCDDevice;        stdcall = nil;
  AdrOpenDevice                   : function  (const aName: PChar; const aParams: PChar)                                                             : TAdrAudioDevice;     stdcall = nil;
  AdrOpenFile                     : function  (aName: PChar; aWritable: LongBool)                                                                    : TAdrFile;            stdcall = nil;
  AdrOpenFileW                    : function  (aName: PWideChar; aWritable: LongBool)                                                                : TAdrFile;            stdcall = nil;
  AdrOpenMIDIDevice               : function  (aName: PChar)                                                                                         : TAdrMIDIDevice;      stdcall = nil;
  AdrOpenSampleSource             : function  (const aFilename: PChar; aFileFormat: TAdrFileFormat)                                                  : TAdrSampleSource;    stdcall = nil;
  AdrOpenSampleSourceFromFile     : function  (aFile: TAdrFile; aFileFormat: TAdrFileFormat)                                                         : TAdrSampleSource;    stdcall = nil;
  AdrOpenSampleSourceW            : function  (const aFilename: PWideChar; aFileFormat: TAdrFileFormat)                                              : TAdrSampleSource;    stdcall = nil;
  AdrOpenSound                    : function  (aDevice: TAdrAudioDevice; aSource: TAdrSampleSource; aStreaming: LongBool)                            : TAdrOutputStream;    stdcall = nil;
  AdrOpenSoundEffect              : function  (aDevice: TAdrAudioDevice; aSource: TAdrSampleSource; aType: TAdrSoundEffectType)                      : TAdrSoundEffect;     stdcall = nil;
  AdrSimpleIsPlaying              : function                                                                                                         : LongBool;            stdcall = nil;
  AdrSimplePlay                   : procedure (aBuffer: Pointer; aSize: Longint; aLoop: LongBool; aFormat: TAdrFileFormat = adrFormatAuto)           ;                      stdcall = nil;
  AdrSimplePlayFile               : procedure (aFilename: PChar; aLoop: LongBool)                                                                    ;                      stdcall = nil;
  AdrSimplePlayFileW              : procedure (aFilename: PWideChar; aLoop: LongBool)                                                                ;                      stdcall = nil;
  AdrSimpleStop                   : procedure                                                                                                        ;                      stdcall = nil;

// Dynamic Loading/Unlocading DLL File
function LoadAudiere(Filename: PChar = nil): Boolean;
procedure UnloadAudiere;

var
  AudiereHandle: HMODULE = 0;

{$ENDIF}

implementation

uses
  Windows;

{ TAdrStopEvent }

function TAdrStopEvent.GetType: TAdrEventType;
begin
  Result := adrEventStop;
end;

{ TAdrStopCallback }

procedure TAdrStopCallback.Ref;
begin
end;

procedure TAdrStopCallback.UnRef;
begin
end;

function TAdrStopCallback.GetType: TAdrEventType;
begin
  Result := adrEventStop;
end;

procedure TAdrStopCallback.call(aEvent: TAdrEvent);
begin
  streamStopped(TAdrStopEvent(aEvent));
end;

{$IFDEF DYNAMIC}

function LoadAudiere(Filename: PChar = nil): Boolean;
begin
  if AudiereHandle <> 0 then
  begin
    Result := True;
    Exit;
  end;

  Result := False;

  if Filename = nil then
  	Filename := AudiereLibrary;
  AudiereHandle := LoadLibrary(Filename);
  if AudiereHandle = 0 then Exit;

  @AdrCreateLoopPointSource        := GetProcAddress ( AudiereHandle, '_AdrCreateLoopPointSource@4'        );
  @AdrCreateMemoryFile             := GetProcAddress ( AudiereHandle, '_AdrCreateMemoryFile@8'             );
  @AdrCreateMemoryFileInPlace      := GetProcAddress ( AudiereHandle, '_AdrCreateMemoryFileInPlace@8'      );
  @AdrCreatePinkNoise              := GetProcAddress ( AudiereHandle, '_AdrCreatePinkNoise@0'              );
  @AdrCreateSampleBuffer           := GetProcAddress ( AudiereHandle, '_AdrCreateSampleBuffer@20'          );
  @AdrCreateSampleBufferFromSource := GetProcAddress ( AudiereHandle, '_AdrCreateSampleBufferFromSource@4' );
  @AdrCreateSquareWave             := GetProcAddress ( AudiereHandle, '_AdrCreateSquareWave@8'             );
  @AdrCreateTone                   := GetProcAddress ( AudiereHandle, '_AdrCreateTone@8'                   );
  @AdrCreateWhiteNoise             := GetProcAddress ( AudiereHandle, '_AdrCreateWhiteNoise@0'             );
  @AdrEnumerateCDDevices           := GetProcAddress ( AudiereHandle, '_AdrEnumerateCDDevices@0'           );
  @AdrGetSampleSize                := GetProcAddress ( AudiereHandle, '_AdrGetSampleSize@4'                );
  @AdrGetSupportedAudioDevices     := GetProcAddress ( AudiereHandle, '_AdrGetSupportedAudioDevices@0'     );
  @AdrGetSupportedFileFormats      := GetProcAddress ( AudiereHandle, '_AdrGetSupportedFileFormats@0'      );
  @AdrGetVersion                   := GetProcAddress ( AudiereHandle, '_AdrGetVersion@0'                   );
  @AdrOpenCDDevice                 := GetProcAddress ( AudiereHandle, '_AdrOpenCDDevice@4'                 );
  @AdrOpenDevice                   := GetProcAddress ( AudiereHandle, '_AdrOpenDevice@8'                   );
  @AdrOpenFile                     := GetProcAddress ( AudiereHandle, '_AdrOpenFile@8'                     );
  @AdrOpenFileW                    := GetProcAddress ( AudiereHandle, '_AdrOpenFileW@8'                    );
  @AdrOpenMIDIDevice               := GetProcAddress ( AudiereHandle, '_AdrOpenMIDIDevice@4'               );
  @AdrOpenSampleSource             := GetProcAddress ( AudiereHandle, '_AdrOpenSampleSource@8'             );
  @AdrOpenSampleSourceFromFile     := GetProcAddress ( AudiereHandle, '_AdrOpenSampleSourceFromFile@8'     );
  @AdrOpenSampleSourceW            := GetProcAddress ( AudiereHandle, '_AdrOpenSampleSourceW@8'            );
  @AdrOpenSound                    := GetProcAddress ( AudiereHandle, '_AdrOpenSound@12'                   );
  @AdrOpenSoundEffect              := GetProcAddress ( AudiereHandle, '_AdrOpenSoundEffect@12'             );
  @AdrSimpleIsPlaying              := GetProcAddress ( AudiereHandle, '_AdrSimpleIsPlaying@0'              );
  @AdrSimplePlay                   := GetProcAddress ( AudiereHandle, '_AdrSimplePlay@16'                  );
  @AdrSimplePlayFile               := GetProcAddress ( AudiereHandle, '_AdrSimplePlayFile@8'               );
  @AdrSimplePlayFileW              := GetProcAddress ( AudiereHandle, '_AdrSimplePlayFileW@8'              );
  @AdrSimpleStop                   := GetProcAddress ( AudiereHandle, '_AdrSimpleStop@0'                   );

  if not ( Assigned (AdrCreateLoopPointSource)        and
           Assigned (AdrCreateMemoryFile)             and
           Assigned (AdrCreateMemoryFileInPlace)      and
           Assigned (AdrCreatePinkNoise)              and
           Assigned (AdrCreateSampleBuffer)           and
           Assigned (AdrCreateSampleBufferFromSource) and
           Assigned (AdrCreateSquareWave)             and
           Assigned (AdrCreateTone)                   and
           Assigned (AdrCreateWhiteNoise)             and
           Assigned (AdrEnumerateCDDevices)           and
           Assigned (AdrGetSampleSize)                and
           Assigned (AdrGetSupportedAudioDevices)     and
           Assigned (AdrGetSupportedFileFormats)      and
           Assigned (AdrGetVersion)                   and
           Assigned (AdrOpenCDDevice)                 and
           Assigned (AdrOpenDevice)                   and
           Assigned (AdrOpenFile)                     and
           Assigned (AdrOpenFileW)                    and
           Assigned (AdrOpenMIDIDevice)               and
           Assigned (AdrOpenSampleSource)             and
           Assigned (AdrOpenSampleSourceFromFile)     and
           Assigned (AdrOpenSampleSourceW)            and
           Assigned (AdrOpenSound)                    and
           Assigned (AdrOpenSoundEffect)              and
           Assigned (AdrSimpleIsPlaying)              and
           Assigned (AdrSimplePlay)                   and
           Assigned (AdrSimplePlayFile)               and
           Assigned (AdrSimplePlayFileW)              and
           Assigned (AdrSimpleStop)
         ) then
  begin
    UnloadAudiere;
    Exit;
  end;

  Result := True;
end;

procedure UnloadAudiere;
begin
  if AudiereHandle <> 0 then
  begin
    FreeLibrary(AudiereHandle);
    AudiereHandle := 0;
  end;
end;

initialization
  // LoadAudiere;

finalization
  UnloadAudiere;

{$ENDIF}

end.


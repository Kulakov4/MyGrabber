unit CommissionOptions;

interface
uses Saver, Dialogs, Graphics;
type
  TStudyProcessOptions = class(TOptions)
  private
    FAcademicYear: Integer;
    FAccessLevel: Integer;
    FAppDataDir: string;
    FAppDir: string;
    FBaseFont: TFont;
    FIDChair: Integer;
    FIDUser: Integer;
    FPassword: string;
//    FPassword: TPassword;
    FReportHost: string;
//    FPassword: TPassword;
    FReportFileServer: string;
    FReportPort: Integer;
    FUserName: string;
    procedure SetAcademicYear(const Value: Integer);
    procedure SetReportHost(const Value: string);
    procedure SetReportFileServer(const Value: string);
    procedure SetReportPort(const Value: Integer);
  protected
    procedure InternalCreate(AObjectName: string); override;
    procedure SetBaseFont(const Value: TFont); virtual;
  public
    destructor Destroy; override;
    property AccessLevel: Integer read FAccessLevel write FAccessLevel;
    property AppDataDir: string read FAppDataDir;
    property AppDir: string read FAppDir;
    property IDChair: Integer read FIDChair write FIDChair;
    property IDUser: Integer read FIDUser write FIDUser;
    property Password: string read FPassword write FPassword;
    property UserName: string read FUserName write FUserName;
  published
    property AcademicYear: Integer read FAcademicYear write SetAcademicYear;
    property BaseFont: TFont read FBaseFont write SetBaseFont;
    property ReportHost: string read FReportHost write SetReportHost;
    property ReportFileServer: string read FReportFileServer write
        SetReportFileServer;
    property ReportPort: Integer read FReportPort write SetReportPort;
  end;

  TCommissionOptions = class(TStudyProcessOptions)
  private
    FIDDisciplineName: Integer;
    procedure SetIDDisciplineName(const Value: Integer);
  protected
    procedure InternalCreate(AObjectName: string); override;
  public
  published
    property IDDisciplineName: Integer read FIDDisciplineName write
        SetIDDisciplineName;
  end;

  TCompetenceOptions = class(TStudyProcessOptions)
  private
    FCompetenceFolder: String;
    FWordTemplateFileName: String;
  protected
    procedure InternalCreate(AObjectName: string); override;
  public
    property CompetenceFolder: String read FCompetenceFolder;
    property WordTemplateFileName: String read FWordTemplateFileName;
  end;

  TStudyPlanOptions = class(TStudyProcessOptions)
  private
    FIDEducationLevel: Integer;
    FIDSpecEducation: Integer;
    FIDSpecEdVO: Integer;
    FIDSpecEdSPO: Integer;
    FIDSpecEdRetraining: Integer;
    FIDStudyPlan: Integer;
    procedure SetIDEducationLevel(const Value: Integer);
    procedure SetIDSpecEducation(const Value: Integer);
    procedure SetIDSpecEdVO(const Value: Integer);
    procedure SetIDSpecEdSPO(const Value: Integer);
    procedure SetIDSpecEdRetraining(const Value: Integer);
    procedure SetIDStudyPlan(const Value: Integer);
  protected
    procedure InternalCreate(AObjectName: string); override;
  published
    property IDEducationLevel: Integer read FIDEducationLevel write
        SetIDEducationLevel;
    property IDSpecEducation: Integer read FIDSpecEducation write
        SetIDSpecEducation;
    property IDSpecEdVO: Integer read FIDSpecEdVO write SetIDSpecEdVO;
    property IDSpecEdSPO: Integer read FIDSpecEdSPO write SetIDSpecEdSPO;
    property IDSpecEdRetraining: Integer read FIDSpecEdRetraining write
        SetIDSpecEdRetraining;
    property IDStudyPlan: Integer read FIDStudyPlan write SetIDStudyPlan;
  end;

  TPersonnelOptions = class(TStudyProcessOptions)
  protected
    procedure InternalCreate(AObjectName: string); override;
  end;

  TUMKOptions = class(TStudyProcessOptions)
  protected
    procedure InternalCreate(AObjectName: string); override;
  end;

Var
  StudyProcessOptions: TStudyProcessOptions;

implementation

uses StudyProcessTools, SysUtils, K_SysUtils, System.IOUtils;

destructor TStudyProcessOptions.Destroy;
begin
  inherited;
  FreeAndNil(FBaseFont);
end;

procedure TStudyProcessOptions.InternalCreate(AObjectName: string);
var
  AFileName: string;
  Error: Boolean;
begin
  FBaseFont := TFont.Create;  // Создаём некоторый шрифт по умолчанию
  FBaseFont.Name := 'Tahoma';
  FBaseFont.Size := 9;

  FAccessLevel := 999;
 // FPassword := TPassword.Create(Self, 'Однажды в студёную зимнюю пору я из лесу вышел');
  FReportFileServer := '\\eduserver\reports';
  FReportHost := 'eduserver';
  FReportPort := 8080;
  FAcademicYear := Integer(GetAcademicYear(Date));

  FAppDir := ExtractFilePath(ParamStr(0));

  FAppDataDir := KGetEnvironmentVariable('APPDATA');
  Error := FAppDataDir = '';
  if not Error then
  begin
    FAppDataDir := TPath.Combine(FAppDataDir, TPath.GetFileNameWithoutExtension(AObjectName));

    TDirectory.CreateDirectory(FAppDataDir);
    Error := not TDirectory.Exists(FAppDataDir);

    FAppDataDir := FAppDataDir + TPath.DirectorySeparatorChar;
  end;

  if Error then
    FAppDataDir := FAppDir;
    
  AFileName := TPath.Combine(FAppDataDir, AObjectName);
  AutoSaveOptions := True;
  inherited InternalCreate(AFileName);
end;

procedure TStudyProcessOptions.SetAcademicYear(const Value: Integer);
begin
  FAcademicYear := Value;
end;

procedure TStudyProcessOptions.SetBaseFont(const Value: TFont);
begin
  FBaseFont.Assign(Value);
end;

procedure TStudyProcessOptions.SetReportHost(const Value: string);
begin
  FReportHost := Value;
end;

procedure TStudyProcessOptions.SetReportFileServer(const Value: string);
begin
  FReportFileServer := Value;
end;

procedure TStudyProcessOptions.SetReportPort(const Value: Integer);
begin
  FReportPort := Value;
end;

procedure TCommissionOptions.InternalCreate(AObjectName: string);
begin
  inherited InternalCreate('commission.ini');
end;

procedure TCommissionOptions.SetIDDisciplineName(const Value: Integer);
begin
  FIDDisciplineName := Value;
end;

procedure TCompetenceOptions.InternalCreate(AObjectName: string);
begin
  FWordTemplateFileName := '\\rfagu\study_process\компетенции\Паспорт компетенции.dot';
  FCompetenceFolder := '\\rfagu\Competence\';
  inherited InternalCreate('competence.ini');
end;

procedure TStudyPlanOptions.InternalCreate(AObjectName: string);
begin
  FIDSpecEducation := 0;
  inherited InternalCreate('studyplan.ini');
end;

procedure TStudyPlanOptions.SetIDEducationLevel(const Value: Integer);
begin
  FIDEducationLevel := Value;
end;

procedure TStudyPlanOptions.SetIDSpecEducation(const Value: Integer);
begin
  FIDSpecEducation := Value;
end;

procedure TStudyPlanOptions.SetIDSpecEdVO(const Value: Integer);
begin
  FIDSpecEdVO := Value;
end;

procedure TStudyPlanOptions.SetIDSpecEdSPO(const Value: Integer);
begin
  FIDSpecEdSPO := Value;
end;

procedure TStudyPlanOptions.SetIDSpecEdRetraining(const Value: Integer);
begin
  FIDSpecEdRetraining := Value;
end;

procedure TStudyPlanOptions.SetIDStudyPlan(const Value: Integer);
begin
  FIDStudyPlan := Value;
end;

procedure TPersonnelOptions.InternalCreate(AObjectName: string);
begin
  inherited InternalCreate('personnel.ini');
end;

procedure TUMKOptions.InternalCreate(AObjectName: string);
begin
  inherited InternalCreate('UMK.ini');
end;

end.

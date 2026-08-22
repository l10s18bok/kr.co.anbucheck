# probe/ios-nse 전용 — NSE 프로브 타겟을 Runner.xcodeproj에 추가한다.
# 재실행 안전(idempotent): 이미 있으면 지우고 다시 만든다.
require 'xcodeproj'

PROJ = File.expand_path('Runner.xcodeproj', __dir__)
NAME = 'ProbeNSE'
BUNDLE = 'kr.co.anbucheck.live.ProbeNSE'
TEAM = '2F3GNTJRBK'

project = Xcodeproj::Project.open(PROJ)
runner  = project.targets.find { |t| t.name == 'Runner' }
raise 'Runner 타겟을 찾을 수 없다' unless runner

# ── 기존 것 정리 ──────────────────────────────────────────────
project.targets.select { |t| t.name == NAME }.each do |t|
  runner.dependencies.select { |d| d.target == t }.each(&:remove_from_project)
  t.remove_from_project
end
project.main_group.children.select { |g| g.display_name == NAME }.each(&:remove_from_project)

# ── 타겟 생성 ─────────────────────────────────────────────────
ext = project.new_target(:app_extension, NAME, :ios, '14.0')

group = project.main_group.new_group(NAME, NAME)
src   = group.new_reference('NotificationService.swift')
group.new_reference('Info.plist')
cfg_ref = group.new_reference('ProbeNSE.xcconfig')
ext.source_build_phase.add_file_reference(src)

ext.build_configurations.each do |c|
  c.base_configuration_reference = cfg_ref
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER']   = BUNDLE
  s['PRODUCT_NAME']                = '$(TARGET_NAME)'
  s['INFOPLIST_FILE']              = "#{NAME}/Info.plist"
  s['GENERATE_INFOPLIST_FILE']     = 'NO'
  s['DEVELOPMENT_TEAM']            = TEAM
  s['CODE_SIGN_STYLE']             = 'Automatic'
  s['SWIFT_VERSION']               = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET']  = '14.0'
  s['TARGETED_DEVICE_FAMILY']      = '1'
  s['SKIP_INSTALL']                = 'YES'
  s['CLANG_ENABLE_MODULES']        = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS']     = ['$(inherited)', '@executable_path/Frameworks',
                                      '@executable_path/../../Frameworks']
  # 확장은 Flutter/Pods와 무관하게 순수 Swift로만 빌드한다
  s['ENABLE_BITCODE']              = 'NO'
end

# ── Runner에 임베드 ───────────────────────────────────────────
runner.add_dependency(ext)

embed = runner.build_phases.find do |ph|
  ph.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase) &&
    ph.name == 'Embed App Extensions'
end
unless embed
  embed = runner.new_copy_files_build_phase('Embed App Extensions')
  embed.symbol_dst_subfolder_spec = :plug_ins
end

# ⚠️ 임베드 페이즈는 Flutter의 'Thin Binary' 스크립트 **앞**에 와야 한다.
# 뒤에 두면 "Cycle inside Runner"로 빌드가 실패한다 — Thin Binary가
# Runner.app/Info.plist를 산출물로 선언하는데 appex 복사가 그 뒤에 오면서
# 의존 그래프가 순환한다(2026-08-22 실측).
runner.build_phases.delete(embed)
thin_idx = runner.build_phases.index { |ph|
  ph.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) && ph.name == 'Thin Binary'
}
runner.build_phases.insert(thin_idx || runner.build_phases.size, embed)
embed.files.select { |f| f.display_name == "#{NAME}.appex" }.each(&:remove_from_project)
build_file = embed.add_file_reference(ext.product_reference)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

project.save
puts "OK: #{NAME} 타겟 생성"
puts "configurations: #{ext.build_configurations.map(&:name).join(', ')}"
puts "embed phase files: #{embed.files.map(&:display_name).join(', ')}"

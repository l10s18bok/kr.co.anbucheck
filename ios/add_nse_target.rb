# iOS heartbeat 확장 타겟을 Runner.xcodeproj에 추가한다. 재실행 안전(idempotent).
#
# ⚠️ 'Embed App Extensions' 복사 페이즈는 Flutter의 'Thin Binary' 스크립트 **앞**에
# 와야 한다. 뒤에 두면 Thin Binary가 Runner.app/Info.plist를 산출물로 선언해
# 의존 그래프가 순환하고 "Cycle inside Runner"로 빌드가 실패한다(실측).
require 'xcodeproj'

PROJ = File.expand_path('Runner.xcodeproj', __dir__)
NAME = 'HeartbeatNSE'
BUNDLE = 'kr.co.anbucheck.live.HeartbeatNSE'
TEAM = '2F3GNTJRBK'

project = Xcodeproj::Project.open(PROJ)
runner = project.targets.find { |t| t.name == 'Runner' }
raise 'Runner 타겟을 찾을 수 없다' unless runner

# ── 기존 것 정리 ──────────────────────────────────────────────
project.targets.select { |t| t.name == NAME }.each do |t|
  runner.dependencies.select { |d| d.target == t }.each(&:remove_from_project)
  t.remove_from_project
end
project.main_group.children.select { |g| g.display_name == NAME }.each(&:remove_from_project)

# ── 공유 소스 그룹 (앱·확장 양쪽이 컴파일) ────────────────────
shared = project.main_group.children.find { |g| g.display_name == 'Shared' } ||
         project.main_group.new_group('Shared', 'Shared')
shared_ref = shared.files.find { |f| f.display_name == 'HeartbeatStore.swift' } ||
             shared.new_reference('HeartbeatStore.swift')
unless runner.source_build_phase.files_references.include?(shared_ref)
  runner.source_build_phase.add_file_reference(shared_ref)
end

# ── 확장 타겟 ─────────────────────────────────────────────────
ext = project.new_target(:app_extension, NAME, :ios, '14.0')
group = project.main_group.new_group(NAME, NAME)
src = group.new_reference('NotificationService.swift')
group.new_reference('Info.plist')
group.new_reference('HeartbeatNSE.entitlements')
cfg_ref = group.new_reference('HeartbeatNSE.xcconfig')
ext.source_build_phase.add_file_reference(src)
ext.source_build_phase.add_file_reference(shared_ref)   # 공유 파일을 확장에도 포함

ext.build_configurations.each do |c|
  c.base_configuration_reference = cfg_ref
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER']  = BUNDLE
  s['PRODUCT_NAME']               = '$(TARGET_NAME)'
  s['INFOPLIST_FILE']             = "#{NAME}/Info.plist"
  s['GENERATE_INFOPLIST_FILE']    = 'NO'
  s['CODE_SIGN_ENTITLEMENTS']     = "#{NAME}/#{NAME}.entitlements"
  s['DEVELOPMENT_TEAM']           = TEAM
  s['CODE_SIGN_STYLE']            = 'Automatic'
  s['SWIFT_VERSION']              = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  s['TARGETED_DEVICE_FAMILY']     = '1'
  s['SKIP_INSTALL']               = 'YES'
  s['ENABLE_BITCODE']             = 'NO'
  s['LD_RUNPATH_SEARCH_PATHS']    = ['$(inherited)', '@executable_path/Frameworks',
                                     '@executable_path/../../Frameworks']
end

# ── Runner에 임베드 (Thin Binary 앞) ──────────────────────────
runner.add_dependency(ext)
embed = runner.build_phases.find do |ph|
  ph.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase) && ph.name == 'Embed App Extensions'
end
unless embed
  embed = runner.new_copy_files_build_phase('Embed App Extensions')
  embed.symbol_dst_subfolder_spec = :plug_ins
end
runner.build_phases.delete(embed)
thin_idx = runner.build_phases.index { |ph|
  ph.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) && ph.name == 'Thin Binary'
}
runner.build_phases.insert(thin_idx || runner.build_phases.size, embed)

embed.files.select { |f| f.display_name == "#{NAME}.appex" }.each(&:remove_from_project)
bf = embed.add_file_reference(ext.product_reference)
bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

project.save
puts "OK: #{NAME} (#{BUNDLE})"
puts "빌드 페이즈: #{runner.build_phases.map { |p| p.respond_to?(:name) && p.name ? p.name : p.class.name.split('::').last }.join(' → ')}"

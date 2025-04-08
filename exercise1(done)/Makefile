# 定义 VCS 命令和参数
VCS = vcs
VCS_FLAGS = -f filelist.f -top tb_top -timescale=1ns/1ns -full64 +define+ -R +neg_tchk +maxdelays +notimingcheck +nospecify +vc +v2k -sverilog +lint=TFIPC-L -debug_access+all -fsdb -incremental
VCS_FLAGS_2 = -f filelist.f -top tb_top_beidou -timescale=1ns/1ns -full64 +define+ -R +neg_tchk +maxdelays +notimingcheck +nospecify +vc +v2k -sverilog +lint=TFIPC-L -debug_access+all -fsdb -incremental

# 定义 Verdi 命令和参数
VERDI = verdi
VERDI_FLAGS = -f filelist.f -ssf tb.fsdb
VERDI_FLAGS_2 = -f filelist.f -ssf tb_beidou.fsdb

# 定义输出日志文件
LOG_FILE = vcs.log
LOG_FILE_2 = vcs_2.log

# 默认目标：编译并仿真
all:file sim 

file:
	find . -name "*.v" > filelist.f

# 编译并运行仿真
sim:
	$(VCS) $(VCS_FLAGS) | tee $(LOG_FILE)

# 任务三编译
sim2:
	$(VCS) $(VCS_FLAGS_2) | tee $(LOG_FILE_2)

# 启动 Verdi 查看波形
wave:
	$(VERDI) $(VERDI_FLAGS) &

# 启动 Verdi 查看波形
wave2:
	$(VERDI) $(VERDI_FLAGS_2) &

# 清理生成的文件
clean:
	rm -rf simv* csrc* *.daidir *.log *.vpd ucli.key verdiLog* novas.* *.fsdb DVE*

# 伪目标声明，确保 make 不会将这些目标当作文件处理
.PHONY: all sim view_wave clean
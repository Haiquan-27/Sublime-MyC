import sublime
import sublime_plugin
import os
import json
import time
 
class MyCsDevTestingCommand(sublime_plugin.TextCommand):
	def run(self,edit):
		shell_cmd = "start subl -a " + '"%s"'%(os.path.split(__file__)[0])
		print(shell_cmd)
		os.system(shell_cmd)

def clear_view(view):
	view.run_command("select_all") # 全选
	view.run_command("right_delete") # 删除

def close_view(view):   
	window = view.window()
	if window != None: # 防脑瘫关闭启动窗口
		window.focus_view(view)
	window.run_command("close")

def get_file_word_point(view,words):
	view_content = view.substr(sublime.Region(0,view.size()))
	point = view_content.find(words)
	return (point,len(words)+point)

class MyCsContextMenuTopToggleCommand(sublime_plugin.TextCommand):
	"""右键菜单项顶置开关"""
	def run(self,edit):
		context_settings_file = os.path.split(__file__)[0]+os.sep+"Context.sublime-menu"
		context_settings = None
		# with open(context_settings_file,mode="r",encoding="utf-8") as file:
		# 	print(file.read())
		# 	context_settings = json.load(file)
		with open(context_settings_file,mode="r",encoding="utf-8") as file:
			context_settings = json.load(file)
		if context_settings[0]["id"] == "end" :
			context_settings[0]["id"] = ""
		else:
			context_settings[0]["id"] = "end"
		with open(context_settings_file,mode="w",encoding="utf-8") as file:
			# context_settings = json.load(file)
			file.write(json.dumps(context_settings,indent=5,ensure_ascii=False))


class MyCsSetViewWithEncodingCommand(sublime_plugin.TextCommand):
	"""设置视图编码"""
	def run(self,edit,encoding:"(st_encoding,ConvertToUtf8_encoding)"=()):
		view = self.view
		view_content = view.substr(sublime.Region(0,view.size()))
		st_encoding = encoding[0]
		ConvertToUtf8_encoding = encoding[1]
		# 清空页面再改编码再将原来的内容复制进去
		def save_file():
			if view.file_name()!=None:
				view.run_command("save")
		clear_view(view)
		save_file()
		view.set_encoding(st_encoding)
		view.run_command("reload_with_encoding",args={"encoding": ConvertToUtf8_encoding})
		view.run_command("convert_to_utf8",args={"encoding": ConvertToUtf8_encoding, "stamp": "0"})
		view.insert(edit,0,view_content)
		save_file()

class MyCsSetViewWithFileCommand(sublime_plugin.TextCommand):
	"""将文件内容设置为视图内容"""
	def run(self,edit,file_path,ft={}):
		view = self.view
		view.set_read_only(False)
		clear_view(view)
		content = ""
		with open(file_path,mode="r",encoding="utf-8") as file:
			# content = file.read()
			for line in file.readlines():
				if line.strip()[:2] != "**":
					content += line
		del file
		content = content.format(**ft)
		view.insert(edit,0,content)

class MyCsMainMenuCommand(sublime_plugin.TextCommand):
	"""
	开始菜单动作
	"""
	def run(self, edit):
		settings = sublime.load_settings("My C.sublime-settings")
		settings_encoding_list = settings.get("file_encoding_list")
		settings_file_syntax = settings.get("file_syntax")
		settings_title_name = settings.get("title_name")
		settings_start_word = settings.get("template_start_word")

		window = self.view.window()
		new_view = window.new_file()
		new_view.set_name("My C Start >_")
		new_view.set_syntax_file(settings_file_syntax) # 设置语法
		logo_file_path = os.path.split(__file__)[0]+os.sep+"Logo.txt"
		template_file_path = os.path.split(__file__)[0]+os.sep+"template.c"

		user_options = list(settings_encoding_list.keys())
		user_options.append("Exit (ESC) 退出")

		def sel_encoding(index):
			new_view.set_read_only(False)
			if index == -1 or user_options[index]=="Exit (ESC) 退出": # 用户选择退出
				clear_view(new_view) # 清空文件
				close_view(new_view) # 关闭文件
				return
			new_view.set_name(settings_title_name) # 设置标签名
			new_view.run_command("my_cs_set_view_with_encoding",args={"encoding":settings_encoding_list[user_options[index]]})
			new_view.run_command("my_cs_set_view_with_file",args={
														"file_path":template_file_path,
														"ft":{
															"date":time.strftime("%Y-%m-%d %H:%M", time.localtime()),
															"encoding":user_options[index]
															}
														})
			new_view.sel().clear()
			start_point,end_point = get_file_word_point(new_view,settings_start_word) # 将选择定位到指定字符
			new_view.sel().add(sublime.Region(start_point,end_point))
			
		new_view.run_command("my_cs_set_view_with_file",args={"file_path":logo_file_path})
		new_view.set_read_only(True)
		window.show_quick_panel(user_options, sel_encoding, sublime.KEEP_OPEN_ON_FOCUS_LOST)

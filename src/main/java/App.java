import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.util.*;

import cn.org.rapid_framework.generator.GeneratorFacade;
import cn.org.rapid_framework.generator.GeneratorProperties;
import cn.org.rapid_framework.generator.provider.db.table.TableFactory;
import cn.org.rapid_framework.generator.provider.db.table.model.Table;
import cn.org.rapid_framework.generator.util.GLogger;

public class App {

    private static Set<PreTemplateFile> preTemplateFiles = new HashSet<PreTemplateFile>();

    public static void main(String[] args) throws Exception {
        GeneratorFacade g = new GeneratorFacade();
        final File file = new File("generator.xml");
        if(file.exists()) {
            GeneratorProperties.load("generator.xml");
            GLogger.info("GeneratorPropeties Load Success, file["+file.getAbsolutePath()+"]");
        }
        final String outRootFilePath = GeneratorProperties.getProperty("dir_crud_out_root");
        g.getGenerator().setOutRootDir(outRootFilePath);
        g.getGenerator().setExcludes(".scss,.ttf,.eot,.woff");
        final String templatesRoot = GeneratorProperties.getProperty("dir_crud_template_root");
        GLogger.info("Template Root ==> "+templatesRoot);
        g.getGenerator().setTemplateRootDirs(templatesRoot.split(","));
        // 按配置增加预处理文件
        addPreTemplateFiles(new File(outRootFilePath).getAbsoluteFile());
        try {
            // 删除生成器的输出目录
            g.deleteOutRootDir();
            // 预处理文件
            for (PreTemplateFile preTemplateFile : preTemplateFiles) {
                try {
                    preTemplateFile.beginProcess();
                } catch (UnsupportedOperationException e) {
                    GLogger.warn("Unimplemented Operation beginProcess."+preTemplateFile.getClass());
                }
            }
            String tables = GeneratorProperties.getProperty("gg_crud_tables");
            List<String> tableList = new ArrayList<String>();
            if (tables != null && tables.length() > 0) {
                String[] ggTables = tables.split(",");
                tableList.addAll(Arrays.asList(ggTables));
            }
            if (args != null && args.length > 0) {
                tableList.addAll(Arrays.asList(args));
            }

            StringBuffer tableNames = new StringBuffer();
            if (!tableList.isEmpty()) {
                for (String tableName : tableList) {
                    Table table = TableFactory.getInstance().getTable(tableName);
                    if (table == null) {
                        GLogger.warn("Not found table ==> "+tableName);
                        continue;
                    }
                    tableNames.append(",");
                    tableNames.append(table.getTableAlias()).append(":");
                    tableNames.append(table.getClassNameFirstLower());
                }
                GeneratorProperties.setProperty("gg_table_name_list", tableNames.substring(1));
                GLogger.info("Generate by table" + tableList);
                g.generateByTable(tableList.toArray(new String[0]));
            }
            // 自动搜索数据库中的所有表并生成文件,template为模板的根目录
            else {
                List<Table> allTables = TableFactory.getInstance().getAllTables();
                for (Table table : allTables) {
                    tableList.add(table.getSqlName());
                    tableNames.append(",").append(table.getTableAlias()).append(":");
                    tableNames.append(table.getClassNameFirstLower());
                }
                GeneratorProperties.setProperty("gg_table_name_list", tableNames.substring(1));
                GLogger.info("Generate by table" + tableList);
                g.generateByAllTable();
            }
        }
        finally {
            for (PreTemplateFile preTemplateFile : preTemplateFiles) {
                try {
                    preTemplateFile.finishProcess();
                } catch (UnsupportedOperationException e) {
                    GLogger.warn("Unimplemented Operation finishProcess."+preTemplateFile.getClass());
                }
            }
        }
    }

    private static void addPreTemplateFiles(File outRootFile) throws ClassNotFoundException, NoSuchMethodException,
            IllegalAccessException, InvocationTargetException, InstantiationException {
        final String cfgClasses = GeneratorProperties.getProperty("gg_crud_pre_bean");
        if (cfgClasses.toString().length() > 0) {
            final String[] classesString = cfgClasses.split(",");
            for (String cls : classesString) {
                if(cls.trim().length() > 0) {
                    PreTemplateFile preTemplateFile = (PreTemplateFile) Class.forName(cls).getConstructor(File.class).newInstance(outRootFile);
                    if (preTemplateFile.support()) {
                        preTemplateFiles.add(preTemplateFile);
                    }
                }
            }
        }
    }
}

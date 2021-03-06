<?xml version="1.0" encoding="UTF-8"?>
<configuration>
	<appender name="FILEINFO"
		class="ch.qos.logback.core.rolling.RollingFileAppender">
		<file><#noparse>${catalina.base}</#noparse>/logs/${artifactId}_warn.log</file>
		<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
			<FileNamePattern><#noparse>${catalina.base}</#noparse>/logs/%d{yyyy-MM-dd}/${artifactId}_warn.log</FileNamePattern>
		</rollingPolicy>
		<filter class="ch.qos.logback.classic.filter.LevelFilter">
			<level>WARN</level>
			<onMatch>ACCEPT</onMatch>
			<onMismatch>DENY</onMismatch>
		</filter>
		<encoder>
			<pattern>%date [%thread] %logger{10} [%file:%line] %msg%n</pattern>
		</encoder>
	</appender>
	<appender name="FILEERROR"
		class="ch.qos.logback.core.rolling.RollingFileAppender">
		<file><#noparse>${catalina.base}</#noparse>/logs/${artifactId}_error.log</file>
		<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
			<FileNamePattern><#noparse>${catalina.base}</#noparse>/logs/%d{yyyy-MM-dd}/${artifactId}_error.log</FileNamePattern>
		</rollingPolicy>
		<filter class="ch.qos.logback.classic.filter.LevelFilter">
			<level>ERROR</level>
			<onMatch>ACCEPT</onMatch>
			<onMismatch>DENY</onMismatch>
		</filter>
		<encoder>
			<pattern>%date [%thread] %logger{10} [%file:%line] %msg%n
			</pattern>
		</encoder>
	</appender>
	<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
		<encoder>
			<pattern>[${artifactId}] %d{yyyy-MM-dd HH:mm:ss.SSS}:[%thread] %-5level %logger{36} - %msg%n</pattern>
		</encoder>
	</appender>

	<logger name="${groupId}.${artifactId}.dao" level="DEBUG"/>
	<logger name="org.ibatis" level="DEBUG" />
	<logger name="net.sf.ehcache" level="WARN" />
	<logger name="org.springframework" level="INFO" />
	<logger name="org.apache.mina" level="WARN" />
	<logger name="org.apache.cxf" level="WARN" />
	<logger name="org.springframework.flex" level="ERROR" />

	<root level="<#noparse>${catalina.log.priority}</#noparse>">
		<appender-ref ref="STDOUT" />
	</root>
</configuration> 
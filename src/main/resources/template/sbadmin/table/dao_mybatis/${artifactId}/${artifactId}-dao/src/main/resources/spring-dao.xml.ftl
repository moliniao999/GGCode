<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mvc="http://www.springframework.org/schema/mvc"
       xmlns:util="http://www.springframework.org/schema/util" xmlns:context="http://www.springframework.org/schema/context"
       xmlns:tx="http://www.springframework.org/schema/tx" xmlns:aop="http://www.springframework.org/schema/aop"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc.xsd
        http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx.xsd
        http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd
        http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util.xsd"
       default-lazy-init="true">

    <bean id="dataSource" class="com.jolbox.bonecp.BoneCPDataSource" destroy-method="close">
        <property name="driverClass" value="<#noparse>${config.dbpool.driverClass}</#noparse>"/>
        <property name="jdbcUrl" value="<#noparse>${config.dbpool.jdbcUrl}</#noparse>"/>
        <property name="username" value="<#noparse>${config.dbpool.username}</#noparse>"/>
        <property name="password" value="<#noparse>${config.dbpool.password}</#noparse>"/>
        <property name="idleConnectionTestPeriodInMinutes" value="<#noparse>${config.dbpool.idleConnectionTestPeriodInMinutes}</#noparse>"/>
        <property name="idleMaxAgeInMinutes" value="<#noparse>${config.dbpool.idleMaxAgeInMinutes}</#noparse>"/>
        <property name="partitionCount" value="<#noparse>${config.dbpool.partitionCount}</#noparse>"/>
        <property name="maxConnectionsPerPartition" value="<#noparse>${config.dbpool.maxConnectionsPerPartition}</#noparse>"/>
        <property name="minConnectionsPerPartition" value="<#noparse>${config.dbpool.minConnectionsPerPartition}</#noparse>"/>
        <property name="acquireIncrement" value="<#noparse>${config.dbpool.acquireIncrement}</#noparse>"/>
        <property name="statementsCacheSize" value="<#noparse>${config.dbpool.statementsCacheSize}</#noparse>"/>
        <property name="releaseHelperThreads" value="<#noparse>${config.dbpool.releaseHelperThreads}</#noparse>"/>
        <property name="connectionTestStatement" value="select 1"/>
    </bean>

    <bean id="transactionManager"
          class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"/>
    </bean>
    <tx:annotation-driven transaction-manager="transactionManager"/>

    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="configLocation" value="classpath:/mybatis.cfg.xml"/>
        <property name="dataSource" ref="dataSource"/>
        <property name="mapperLocations">
            <list>
                <value>classpath:/mybatis/*Mapper.xml</value>
            </list>
        </property>
    </bean>

    <bean id="sqlSessionTemplate" class="org.mybatis.spring.SqlSessionTemplate">
        <constructor-arg index="0" ref="sqlSessionFactory"/>
    </bean>

    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <property name="annotationClass" value="org.springframework.stereotype.Component"/>
        <property name="basePackage" value="${groupId}.${artifactId}.dao"/>
        <property name="sqlSessionTemplateBeanName" value="sqlSessionTemplate"/>
    </bean>

</beans>
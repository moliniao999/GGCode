<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mvc="http://www.springframework.org/schema/mvc"
       xmlns:util="http://www.springframework.org/schema/util" xmlns:context="http://www.springframework.org/schema/context"
       xmlns:tx="http://www.springframework.org/schema/tx" xmlns:aop="http://www.springframework.org/schema/aop"
       xmlns:cache="http://www.springframework.org/schema/cache" xmlns:p="http://www.springframework.org/schema/p"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
		http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc.xsd
        http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx.xsd
        http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd
        http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util.xsd
		http://www.springframework.org/schema/cache http://www.springframework.org/schema/cache/spring-cache-3.2.xsd"
       default-lazy-init="true">

    <!-- dummy cacheManager  -->
    <bean id="cacheManager" class="org.springframework.cache.support.CompositeCacheManager">
        <property name="cacheManagers">
            <list>
                <ref bean="simpleCacheManager" />
            </list>
        </property>
        <property name="fallbackToNoOpCache" value="true" />
    </bean>
    <bean id="simpleCacheManager" class="org.springframework.cache.support.SimpleCacheManager">
        <property name="caches">
            <set>
                <#if cache_ForRedis == "true" && support_Redis == "true">
                <!--1天缓存-->
                <bean class="org.springframework.data.redis.cache.RedisCache">
                    <constructor-arg index="0" value="oneDay"/>
                    <constructor-arg index="1" value=""/>
                    <constructor-arg index="2" ref="cache.template"/>
                    <!--过期时间:秒-->
                    <constructor-arg index="3" value="86400"/>
                </bean>
                <!--5分钟缓存-->
                <bean class="org.springframework.data.redis.cache.RedisCache">
                    <constructor-arg index="0" value="fiveMinutes"/>
                    <constructor-arg index="1" value=""/>
                    <constructor-arg index="2" ref="cache.template"/>
                    <!--过期时间:秒-->
                    <constructor-arg index="3" value="300"/>
                </bean>
                <!--1分钟缓存-->
                <bean class="org.springframework.data.redis.cache.RedisCache">
                    <constructor-arg index="0" value="oneMinutes"/>
                    <constructor-arg index="1" value=""/>
                    <constructor-arg index="2" ref="cache.template"/>
                    <!--过期时间:秒-->
                    <constructor-arg index="3" value="60"/>
                </bean>
                <!--5秒缓存-->
                <bean class="org.springframework.data.redis.cache.RedisCache">
                    <constructor-arg index="0" value="transient"/>
                    <constructor-arg index="1" value=""/>
                    <constructor-arg index="2" ref="cache.template"/>
                    <!--过期时间:秒-->
                    <constructor-arg index="3" value="5"/>
                </bean>
                </#if>
                <!--基于 java.util.concurrent.ConcurrentHashMap 的一个内存缓存实现方案-->
                <bean class="org.springframework.cache.concurrent.ConcurrentMapCache">
                    <constructor-arg index="0" value="default"/>
                </bean>
            </set>
        </property>
    </bean>
    <bean id="cacheKeyGenerator" class="${groupId}.${artifactId}.manager.utils.CacheKeyGenerator">
        <property name="prefix" value="<#noparse>${config.cache.key.prefix}</#noparse>"/>
    </bean>
    <#if support_Redis == "true">
    <bean id="stringRedisSerializer" class="${groupId}.${artifactId}.manager.utils.StringRedisSerializer">
        <property name="prefix" value="<#noparse>${config.cache.key.prefix}</#noparse>"/>
    </bean>

	<bean id="jedisPoolConfig" class="redis.clients.jedis.JedisPoolConfig">
		<!-- <property name="maxActive" value="1000" /> -->
		<property name="maxIdle" value="500" />
		<!-- <property name="maxWait" value="1000" /> -->
		<property name="testOnBorrow" value="true" />
	</bean>
	<bean id="jedis.shardInfo1" class="redis.clients.jedis.JedisShardInfo">
        <constructor-arg index="0" value="<#noparse>${config.redis1.host}</#noparse>" type="java.lang.String"/>
        <constructor-arg index="1" value="<#noparse>${config.redis1.port}</#noparse>" type="int"/>
        <constructor-arg index="2" value="jedis.shardInfo1" type="java.lang.String"/>
        <property name="password" value="<#noparse>${config.redis1.password}</#noparse>" />
    </bean>

	<bean id="shardedJedisPool" class="redis.clients.jedis.ShardedJedisPool">
		<constructor-arg index="0" ref="jedisPoolConfig" />
		<constructor-arg index="1">
			<list>
				<ref bean="jedis.shardInfo1" />
			</list>
		</constructor-arg>
	</bean>

	<bean id="cache.connectionFactory" class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory">
		<property name="shardInfo" ref="jedis.shardInfo1" />
		<property name="poolConfig" ref="jedisPoolConfig" />
		<property name="usePool" value="true" />
	</bean>
	<bean id="cache.template" class="org.springframework.data.redis.core.RedisTemplate">
        <property name="connectionFactory" ref="cache.connectionFactory" />
        <property name="keySerializer" ref="stringRedisSerializer" />
        <property name="hashKeySerializer" ref="stringRedisSerializer" />
	</bean>
    </#if>
</beans>

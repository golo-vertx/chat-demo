module chat

import io.vertx.lang.golo.GoloVerticleFactory
import io.vertx.golo.core.Vertx
import io.vertx.core.VertxOptions
import io.vertx.core.DeploymentOptions
#import java.lang.Thread
import io.vertx.core.eventbus.DeliveryOptions


#function chatVertStart = |verticle|{
#	let vertx = verticle: getVertx()
#    let eb = vertx: eventBus()
#    eb: consumer("chat-demo"):handler(|msg|{
#    	println("[Chat-Demo] Received Msg from "+msg:headers():get("sent-by")+ " : " + msg:body())
#    })
#}

#var deployed = false

function main = |args|{
	var chatVertStart = |verticle|{
		let vertx = verticle: getVertx()
    	let eb = vertx: eventBus()
    	eb: consumer("chat-demo"):handler(|msg|{
    		println("[Chat-Demo] Received Msg from "+msg:headers():get("sent-by")+ " : " + msg:body())
    	})
	}
	var chatVert = GoloVerticleFactory():createGoloVerticle(chatVertStart,|v|{})

	io.vertx.core.Vertx.clusteredVertx(VertxOptions(),|rep|{
        let vertx = rep:result() 
        let eb = vertx:eventBus()
        println(chatVert)
        vertx: deployVerticle(chatVert,|v|{
        	println("Chat Running!")
        	eb:publish("chat-demo","this is missing!!",DeliveryOptions():addHeader("sent-by","xxx"))
        	var mainBlockingCode = {
				var userName = readln("Enter User Name? ")
				println("username - " + userName)
				var finish = false
				while(not finish){
					var msg = readln()
					if(msg == "exit"){
						finish = true
					}
					println("msg - " + msg)
					eb:publish("chat-demo",msg,DeliveryOptions():addHeader("sent-by",userName))
				}
				return "Stopping Chat Program"
			}
			vertx:executeBlocking(|f|->f:complete(mainBlockingCode()),|r|->println(r))
			#println("new creating working")
			#var worker = GoloVerticleFactory():createGoloVerticle(|v|{},|v|{})
			#println("now deploying verticle")
			#vertx: deployVerticle(worker,DeploymentOptions():setWorker(true))
			println("deployment fin!")
			#worker:setPeriodic(1,workerStart)
        })
    })

    #Thread.sleep(10000_L)
    #for (var i = 0, i < 10000, i = i + 1) {
    #	println("[waiting]" + i)
  	#}
    #println("[NOOoooooooooooooo]Should start now...")
	#while(true){
	#	var msg1 = "rnd msgggghggggggggggggggg"
	#	chatVert:getVertx():eventBus():publish("chat-demo",msg,map[["sent-by",userName]])
	#}
	#Thread.sleep(60000_L)
	#while(true){
		#println("deployed = " + deployed)
		#if(deployed){
		#	println("here!!")
		#	chatVert:getVertx():eventBus():publish("chat-demo","this is missing!!",DeliveryOptions():addHeader("sent-by",userName1))
		#}
	#}
	
}


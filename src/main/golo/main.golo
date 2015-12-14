module chat

import io.vertx.core.Vertx
import io.vertx.core.VertxOptions
import io.vertx.core.eventbus.DeliveryOptions
import io.vertx.spi.cluster.hazelcast.HazelcastClusterManager
import com.hazelcast.config.Config

function main = |args|{

	var hazelcastConfig = Config():setProperty("hazelcast.logging.type", "none")
	var userName = readln("Enter User Name? ")
	println("Waiting for chat program to start...")
	Vertx.clusteredVertx(VertxOptions():setClusterManager(HazelcastClusterManager(hazelcastConfig)),|rep|{
        let vertx = rep:result() 
        let eb = vertx:eventBus()
        eb: consumer("chat-demo"):handler(|msg|{
        	var sender = msg:headers():get("sent-by")
        	if(sender == userName){
        		println("msg : '"+msg:body()+"', sent successfully!")
        	} else if(sender == "[user-chanel]"){
        		println("[INFO] " + msg:body() + " is online.")
        	} else{
    			println("[ALERT] Received Msg from "+ sender + " : " + msg:body())
    		}
    	})
    	eb:publish("chat-demo",userName,DeliveryOptions():addHeader("sent-by","[user-chanel]"))
    	var mainBlockingCode = {
			var finish = false
			while(not finish){
				var msg = readln()
				if(msg == "exit"){
					finish = true
				}
				eb:publish("chat-demo",msg,DeliveryOptions():addHeader("sent-by",userName))
			}
			return "Stopping Chat Program"
		}
        println("Chat Program Running!")	
		vertx:executeBlocking(|f|->f:complete(mainBlockingCode()),|r|->println(r:result()))
    })
}

package com.heroku.jvmoptions;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import com.sun.management.HotSpotDiagnosticMXBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.lang.management.ManagementFactory;
import java.util.Arrays;
import java.util.stream.Collectors;

@RestController
public class JvmOptionsController {
    @GetMapping("/")
    public JsonObject index(@RequestParam(value = "vmoptions", defaultValue = "") String vmOptions, @Autowired Gson gson) {
        var bean = ManagementFactory.getPlatformMXBean(HotSpotDiagnosticMXBean.class);

        var response = new JsonObject();

        var options = Arrays.stream(vmOptions.split(","))
                .map(String::trim)
                .filter(option -> !option.isEmpty())
                .toList();

        for (var option : options) {
            response.add(option, new JsonPrimitive(bean.getVMOption(option).getValue()));
        }

        return response;
    }
}

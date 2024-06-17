package com.heroku.jvmoptions;

import com.sun.management.HotSpotDiagnosticMXBean;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.lang.management.ManagementFactory;

@RestController
public class JvmOptionsController {
    @GetMapping("/")
    public String index() {
        var bean = ManagementFactory.getPlatformMXBean(HotSpotDiagnosticMXBean.class);
        var options = new String[]{"MaxRAM"};

        var result = new StringBuilder();
        for (var option : options) {
            result.append(option);
            result.append("=");
            result.append(bean.getVMOption(option).getValue());
        }

        return result.toString();
    }
}

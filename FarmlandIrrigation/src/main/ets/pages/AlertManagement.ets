// 异常提醒功能页面
// 【数据请求点】需要实时获取土壤湿度、温湿度等传感器数据，判断是否超出阈值
// 【数据存储点】需要存储报警配置参数（阈值设置、通知方式等）和历史报警记录

import notificationManager from '@ohos.notificationManager';
import { BusinessError } from '@ohos.base';

// 报警类型枚举
enum AlertType {
  SOIL_MOISTURE = 'soil_moisture',
  TEMPERATURE = 'temperature', 
  HUMIDITY = 'humidity',
  LIGHT = 'light'
}

// 报警级别枚举
enum AlertLevel {
  WARNING = 'warning',
  CRITICAL = 'critical'
}

// 报警配置数据接口
interface AlertConfig {
  id: string;
  type: AlertType;
  name: string;
  minThreshold: number;
  maxThreshold: number;
  enabled: boolean;
  level: AlertLevel;
  notificationEnabled: boolean;
}

// 报警记录数据接口
interface AlertRecord {
  id: string;
  type: AlertType;
  level: AlertLevel;
  message: string;
  value: number;
  threshold: number;
  timestamp: number;
  resolved: boolean;
}

@Entry
@Component
export default struct AlertManagement {
  @State alertConfigs: AlertConfig[] = [
    {
      id: '1',
      type: AlertType.SOIL_MOISTURE,
      name: '土壤湿度',
      minThreshold: 30,
      maxThreshold: 80,
      enabled: true,
      level: AlertLevel.WARNING,
      notificationEnabled: true
    },
    {
      id: '2', 
      type: AlertType.TEMPERATURE,
      name: '环境温度',
      minThreshold: 5,
      maxThreshold: 35,
      enabled: true,
      level: AlertLevel.CRITICAL,
      notificationEnabled: true
    },
    {
      id: '3',
      type: AlertType.HUMIDITY,
      name: '环境湿度',
      minThreshold: 40,
      maxThreshold: 90,
      enabled: true,
      level: AlertLevel.WARNING,
      notificationEnabled: false
    },
    {
      id: '4',
      type: AlertType.LIGHT,
      name: '光照强度',
      minThreshold: 100,
      maxThreshold: 100000,
      enabled: false,
      level: AlertLevel.WARNING,
      notificationEnabled: true
    }
  ];

  @State alertRecords: AlertRecord[] = [];
  @State currentSensorData: Record<string, number> = {
    "soilMoisture": 25, // 模拟当前土壤湿度过低
    "temperature": 38,  // 模拟当前温度过高
    "humidity": 45,
    "lightIntensity": 2000
  };
  @State isMonitoring: boolean = true;

  aboutToAppear() {
    this.loadAlertConfigs();
    this.loadAlertRecords();
    this.startMonitoring();
  }

  // 【数据存储点】加载报警配置
  // 此处应连接本地数据库读取用户设置的报警配置参数
  // 建议存储格式：alert_configs表 (id, type, name, min_threshold, max_threshold, enabled, level, notification_enabled)
  loadAlertConfigs() {
    console.info('加载报警配置 - 此处应从数据库读取用户配置的报警参数');
  }

  // 【数据存储点】加载历史报警记录
  // 此处应连接数据库读取历史报警记录
  // 建议存储格式：alert_records表 (id, type, level, message, value, threshold, timestamp, resolved)
  loadAlertRecords() {
    console.info('加载历史报警记录 - 此处应从数据库读取历史报警数据');
    
    // 模拟历史报警记录
    this.alertRecords = [
      {
        id: '1',
        type: AlertType.SOIL_MOISTURE,
        level: AlertLevel.WARNING,
        message: '土壤湿度过低',
        value: 25,
        threshold: 30,
        timestamp: Date.now() - 3600000,
        resolved: false
      },
      {
        id: '2',
        type: AlertType.TEMPERATURE,
        level: AlertLevel.CRITICAL,
        message: '环境温度过高',
        value: 38,
        threshold: 35,
        timestamp: Date.now() - 1800000,
        resolved: false
      }
    ];
  }

  // 【数据请求点】获取实时传感器数据
  // 此处需要调用南向设备API或云端API获取实时传感器数据
  // 建议请求参数：设备ID、数据类型（土壤湿度、温度、湿度、光照等）
  // 返回格式：{timestamp: number, soilMoisture: number, temperature: number, humidity: number, lightIntensity: number}
  async fetchRealTimeData() {
    console.info('获取实时传感器数据 - 此处应调用设备API获取实时数据');
    
    // 模拟数据更新
    this.currentSensorData = {
      "soilMoisture": Math.random() * 100,
      "temperature": 20 + Math.random() * 20,
      "humidity": 40 + Math.random() * 40,
      "lightIntensity": Math.random() * 10000
    };
  }

  // 启动监控
  startMonitoring() {
    if (this.isMonitoring) {
      setInterval(async () => {
        await this.fetchRealTimeData();
        this.checkAlerts();
      }, 5000); // 每5秒检查一次
    }
  }

  // 【数据请求点】检查是否触发报警
  // 依赖的实时数据字段：土壤湿度值、环境温度值、环境湿度值、光照强度值
  // 判断逻辑：将实时数据与用户配置的阈值范围进行比较
  checkAlerts() {
    console.info('检查报警条件 - 基于实时数据判断是否超出用户设定阈值');
    
    this.alertConfigs.forEach(config => {
      if (!config.enabled) return;

      let currentValue = 0;
      let fieldName = '';

      switch (config.type) {
        case AlertType.SOIL_MOISTURE:
          currentValue = this.currentSensorData.soilMoisture;
          fieldName = '土壤湿度';
          break;
        case AlertType.TEMPERATURE:
          currentValue = this.currentSensorData.temperature;
          fieldName = '环境温度';
          break;
        case AlertType.HUMIDITY:
          currentValue = this.currentSensorData.humidity;
          fieldName = '环境湿度';
          break;
        case AlertType.LIGHT:
          currentValue = this.currentSensorData.lightIntensity;
          fieldName = '光照强度';
          break;
      }

      // 检查是否超出阈值范围
      if (currentValue < config.minThreshold || currentValue > config.maxThreshold) {
        this.triggerAlert(config, currentValue, fieldName);
      }
    });
  }

  // 触发报警
  triggerAlert(config: AlertConfig, value: number, fieldName: string) {
    const threshold = value < config.minThreshold ? config.minThreshold : config.maxThreshold;
    const condition = value < config.minThreshold ? '过低' : '过高';
    const message = `${fieldName}${condition}：当前值${value.toFixed(1)}，阈值${threshold}`;

    // 【数据存储点】保存报警记录到数据库
    // 此处应将报警记录保存到数据库
    // 存储字段：报警类型、级别、消息、当前值、阈值、时间戳、是否已处理
    const alertRecord: AlertRecord = {
      id: Date.now().toString(),
      type: config.type,
      level: config.level,
      message: message,
      value: value,
      threshold: threshold,
      timestamp: Date.now(),
      resolved: false
    };

    this.alertRecords.unshift(alertRecord);
    console.info(`保存报警记录 - 此处应将报警记录存入数据库: ${JSON.stringify(alertRecord)}`);

    // 发送通知
    if (config.notificationEnabled) {
      this.sendNotification(message, config.level);
    }
  }

  // 发送系统通知
  async sendNotification(message: string, level: AlertLevel) {
    try {
      // todo 修复：使用正确的notificationManager导入和ContentType类型
      await notificationManager.publish({
        id: Date.now(),
        content: {
          // contentType: 'NOTIFICATION_CONTENT_BASIC_TEXT',
          normal: {
            title: '农田监测报警',
            text: message,
            additionalText: level === AlertLevel.CRITICAL ? '紧急' : '警告'
          }
        },
        actionButtons: [
          {
            title: '查看详情',
            wantAgent: {
              bundleName: 'com.example.farmmonitoring',
              abilityName: 'EntryAbility'
            }
          }
        ]
      });
    } catch (error) {
      console.error('发送通知失败:', error);
    }
  }

  // 【数据存储点】保存报警配置
  // 此处应将修改后的配置保存到数据库
  saveAlertConfig(config: AlertConfig) {
    console.info(`保存报警配置 - 此处应将配置更新到数据库: ${JSON.stringify(config)}`);
    
    const index = this.alertConfigs.findIndex(item => item.id === config.id);
    if (index >= 0) {
      this.alertConfigs[index].type = config.type;
      this.alertConfigs[index].name = config.name;
      this.alertConfigs[index].minThreshold = config.minThreshold;
      this.alertConfigs[index].maxThreshold = config.maxThreshold;
      this.alertConfigs[index].enabled = config.enabled;
      this.alertConfigs[index].level = config.level;
      this.alertConfigs[index].notificationEnabled = config.notificationEnabled;
    }
  }

  // 标记报警为已处理
  markAlertResolved(alertId: string) {
    const index = this.alertRecords.findIndex(item => item.id === alertId);
    if (index !== -1) {
      // 创建新数组以触发状态更新
      const newRecords = [...this.alertRecords];
      newRecords[index] = {
        id: newRecords[index].id,
        type: newRecords[index].type,
        level: newRecords[index].level,
        message: newRecords[index].message,
        value: newRecords[index].value,
        threshold: newRecords[index].threshold,
        timestamp: newRecords[index].timestamp,
        resolved: true
      };
      this.alertRecords = newRecords;

      console.info(`标记报警已处理 - 此处应更新数据库记录: ${alertId}`);
    }
  }

  build() {
    Column({ space: 16 }) {
      // 标题栏
      Row() {
        Text('异常提醒管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })

      Scroll() {
        Column({ space: 16 }) {
          // 监控状态
          Row() {
            Text('监控状态：')
              .fontSize(16)
              .fontColor('#666666')
            
            Toggle({ type: ToggleType.Switch, isOn: this.isMonitoring })
              .selectedColor('#007DFF')
              .onChange((isOn: boolean) => {
                this.isMonitoring = isOn;
                if (isOn) {
                  this.startMonitoring();
                }
              })
            
            Text(this.isMonitoring ? '运行中' : '已停止')
              .fontSize(14)
              .fontColor(this.isMonitoring ? '#52C41A' : '#FF4D4F')
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .padding(16)
          .backgroundColor('#F8F9FA')
          .borderRadius(8)

          // 当前数据状态
          Column({ space: 8 }) {
            Text('当前传感器数据')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Grid() {
              GridItem() {
                this.SensorDataCard('土壤湿度', this.currentSensorData.soilMoisture, '%', '#1890FF')
              }
              GridItem() {
                this.SensorDataCard('环境温度', this.currentSensorData.temperature, '°C', '#FF7875')
              }
              GridItem() {
                this.SensorDataCard('环境湿度', this.currentSensorData.humidity, '%', '#52C41A')
              }
              GridItem() {
                this.SensorDataCard('光照强度', this.currentSensorData.lightIntensity, 'lux', '#FFA940')
              }
            }
            .columnsTemplate('1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .height(180)
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })

          // 报警配置
          Column({ space: 12 }) {
            Text('报警配置')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            ForEach(this.alertConfigs, (config: AlertConfig) => {
              this.AlertConfigCard(config)
            })
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })

          // 报警记录
          Column({ space: 12 }) {
            Row() {
              Text('报警记录')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              Blank()
              
              Text(`共${this.alertRecords.length}条`)
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('100%')

            if (this.alertRecords.length > 0) {
              ForEach(this.alertRecords, (record: AlertRecord) => {
                this.AlertRecordCard(record)
              })
            } else {
              Text('暂无报警记录')
                .fontSize(14)
                .fontColor('#999999')
                .textAlign(TextAlign.Center)
                .padding(32)
            }
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
        }
      }
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder SensorDataCard(title: string, value: number, unit: string, color: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(12)
        .fontColor('#666666')
      
      Text(`${value.toFixed(1)}${unit}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F8F9FA')
    .borderRadius(6)
    .padding(8)
  }

  @Builder AlertConfigCard(config: AlertConfig) {
    Column({ space: 8 }) {
      Row() {
        Text(config.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Blank()
        
        Toggle({ type: ToggleType.Switch, isOn: config.enabled })
          .selectedColor('#007DFF')
          .onChange((isOn: boolean) => {
            config.enabled = isOn;
            this.saveAlertConfig(config);
          })
      }
      .width('100%')

      Row() {
        Text('阈值范围：')
          .fontSize(12)
          .fontColor('#666666')
        
        TextInput({ text: config.minThreshold.toString() })
          .width(60)
          .height(28)
          .fontSize(12)
          .onChange((value: string) => {
            config.minThreshold = parseFloat(value) || 0;
            this.saveAlertConfig(config);
          })
        
        Text(' - ')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 4, right: 4 })
        
        TextInput({ text: config.maxThreshold.toString() })
          .width(60)
          .height(28)
          .fontSize(12)
          .onChange((value: string) => {
            config.maxThreshold = parseFloat(value) || 0;
            this.saveAlertConfig(config);
          })
        
        Blank()
        
        Text(config.level === AlertLevel.CRITICAL ? '紧急' : '警告')
          .fontSize(12)
          .fontColor(config.level === AlertLevel.CRITICAL ? '#FF4D4F' : '#FA8C16')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor(config.level === AlertLevel.CRITICAL ? '#FFF1F0' : '#FFF7E6')
          .borderRadius(4)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        Toggle({ type: ToggleType.Checkbox, isOn: config.notificationEnabled })
          .selectedColor('#007DFF')
          .onChange((isOn: boolean) => {
            config.notificationEnabled = isOn;
            this.saveAlertConfig(config);
          })
        
        Text('启用通知推送')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 6 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F8F9FA')
    .borderRadius(6)
  }

  @Builder AlertRecordCard(record: AlertRecord) {
    Column({ space: 12 }) {
      // 顶部信息行
      Row() {
        Column({ space: 4 }) {
          Text(record.message)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: 8 }) {
            Text(new Date(record.timestamp).toLocaleString())
              .fontSize(12)
              .fontColor('#999999')

            Text(`当前值：${record.value.toFixed(1)}`)
              .fontSize(12)
              .fontColor('#666666')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 级别标签
        Text(record.level === AlertLevel.CRITICAL ? '🔴 紧急' : '🟡 警告')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(record.level === AlertLevel.CRITICAL ? '#FF4D4F' : '#FA8C16')
          .borderRadius(12)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 分隔线
      Divider()
        .color('#F0F0F0')

      // 底部操作区
      Row() {
        // 状态指示
        Row({ space: 6 }) {
          Circle({ width: 8, height: 8 })
            .fill(record.resolved ? '#52C41A' : '#FF4D4F')

          Text(record.resolved ? '已处理' : '待处理')
            .fontSize(13)
            .fontColor(record.resolved ? '#52C41A' : '#FF4D4F')
            .fontWeight(FontWeight.Medium)
        }

        Blank()

        // 操作按钮
        if (!record.resolved) {
          Button() {
            Row({ space: 6 }) {
              Text('✓')
                .fontSize(14)
                .fontColor('#FFFFFF')
              Text('标记已处理')
                .fontSize(13)
                .fontColor('#FFFFFF')
            }
          }
          .backgroundColor('#1890FF')
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .shadow({
            radius: 6,
            color: '#1890FF40',
            offsetX: 0,
            offsetY: 2
          })
          .onClick(() => {
            this.markAlertResolved(record.id);
          })
        } else {
          Row({ space: 6 }) {
            Text('✓')
              .fontSize(14)
              .fontColor('#52C41A')
            Text('处理完成')
              .fontSize(13)
              .fontColor('#52C41A')
              .fontWeight(FontWeight.Medium)
          }
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor('#F6FFED')
          .borderRadius(20)
          .border({ width: 1, color: '#B7EB8F' })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({
      width: 2,
      color: record.resolved ? '#F0F0F0' : (record.level === AlertLevel.CRITICAL ? '#FFE7E7' : '#FFF7E6')
    })
    .shadow({
      radius: record.resolved ? 4 : 8,
      color: record.resolved ? '#00000008' : (record.level === AlertLevel.CRITICAL ? '#FF4D4F20' : '#FA8C1620'),
      offsetX: 0,
      offsetY: 2
    })
  }
}
import * as admin from 'firebase-admin';
import { Injectable, OnModuleInit } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs';

@Injectable()
export class FirebaseAdminConfig implements OnModuleInit {
  onModuleInit() {
    const serviceAccountPath = path.join(process.cwd(), 'firebase-service-account.json');
    
    if (fs.existsSync(serviceAccountPath)) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccountPath),
      });
      console.log('Firebase Admin initialized with service account.');
    } else {
      console.warn(
        'WARNING: firebase-service-account.json not found. Firebase Auth will not work until provided.',
      );
      // For development, we might not want to crash the app, 
      // but in production this should be a fatal error.
    }
  }

  async verifyIdToken(idToken: string): Promise<admin.auth.DecodedIdToken> {
    return admin.auth().verifyIdToken(idToken);
  }
}
